#include <stdio.h>
#include <malloc.h>

#define CAPACITY 4
#define SUBPAGE 0xfff
#define INDEX 97

unsigned long long access = 0;
unsigned long long write_back = 0;

typedef struct addr {
	unsigned head;
	unsigned tail;
	addr* next;
}*Addr;
typedef struct pageNode {
	unsigned long long page_num;
	pageNode* llink;
	pageNode* rlink;
	Addr first;
	int dirty;
}*Page;
typedef struct fifoList {
	Page list_head;
	Page list_tail;
	unsigned list_size;
}*FIFOList, ** Cache;

void insert(Page p, unsigned offset, unsigned size)
{
	Addr tmp = p->first, left = p->first;

	// 比第一个结点还小 
	if (offset + size < tmp->head) {
		//		printf("比第一个结点还小\n");
		Addr ad = (Addr)malloc(sizeof(addr));
		ad->head = offset;
		ad->tail = offset + size - 1;
		ad->next = p->first;
		p->first = ad;
		return;
	}

	while (tmp != NULL) {
		if (tmp->tail + 1 >= offset) break;
		left = tmp;
		tmp = tmp->next;
	}

	// 1.在这之后开辟 
	if (tmp == NULL) {
		//		printf("1.在这之后开辟\n");
		Addr ad = (Addr)malloc(sizeof(addr));
		ad->head = offset;
		ad->tail = offset + size - 1;
		ad->next = NULL;
		left->next = ad;
		return;
	}
	// 2.在这之前开辟 	
	else if (offset + size < tmp->head) {
		//		printf("2.在这之前开辟\n");
		Addr ad = (Addr)malloc(sizeof(addr));
		ad->head = offset;
		ad->tail = offset + size - 1;
		ad->next = tmp;
		left->next = ad;
		return;
	}
	// 3.合并分区 
	else {
		//		printf("3.合并分区\n");
		tmp->head = tmp->head < offset ? tmp->head : offset;
		tmp->tail = tmp->tail > (offset + size - 1) ? tmp->tail : (offset + size - 1);
		while (tmp->next && tmp->tail >= tmp->next->head) {
			tmp->tail = tmp->tail > tmp->next->tail ? tmp->tail : tmp->next->tail;
			Addr t = tmp->next;
			tmp->next = tmp->next->next;
			free(t);
		}
	}
}

void PrintSize(Page p, FILE* fp)
{
	unsigned size = 0;
	Addr ad = p->first;
	while (ad) {
		size += ad->tail - ad->head + 1;
		//		printf("ad->head=%x ad->tail=%x size=%u \n", ad->head, ad->tail, size);
		Addr tmp = ad;
		ad = ad->next;
		free(tmp);
	}
	//printf("出队并输出   %llx %u\n", p->page_num, size);
	fprintf(fp, "%llx %u\n", p->page_num, size);
	if(p->dirty){
		write_back++;
	}
}

// 将页面 pg 插入 list队首 
void listInsert(FIFOList fifo, Page pg)
{
	if (fifo->list_size == 0) {
		pg->llink = NULL;
		pg->rlink = NULL;
		fifo->list_head = pg;
		fifo->list_tail = pg;
		fifo->list_size = 1;
		return;
	}
	Page tmp_pg = fifo->list_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	fifo->list_head = pg;
	fifo->list_size += 1;
}
// 删除 list队尾页面  并输出 
void listDelete(FIFOList fifo, FILE* fp)
{
	Page tmp_pg = fifo->list_tail;
	if (tmp_pg->llink)
	{
		tmp_pg->llink->rlink = NULL;
		fifo->list_tail = tmp_pg->llink;
	}
	else {
		fifo->list_head = NULL;
		fifo->list_tail = NULL;
	}
	fifo->list_size -= 1;

	PrintSize(tmp_pg, fp);
	free(tmp_pg);
}

void createPage(FIFOList fifo, unsigned long long tmp_page_num, unsigned offset, unsigned tmp_size, FILE* fp, int is_write)
{
	int flag = 0;

	if (fifo->list_size == 0)
	{
		Page pg = (Page)malloc(sizeof(pageNode));
		pg->llink = NULL;
		pg->rlink = NULL;
		pg->page_num = tmp_page_num;
		if(is_write)
			pg->dirty = 1;

		pg->first = (Addr)malloc(sizeof(addr));
		pg->first->head = offset;
		pg->first->tail = offset + tmp_size - 1;
		pg->first->next = NULL;
		fifo->list_head = pg;
		fifo->list_tail = pg;
		fifo->list_size = 1;
		return;
	}
	else {
		Page tmp_pg = NULL;
		// list非空 则在 list 队中查找 
		if (fifo->list_size > 0) {
			tmp_pg = fifo->list_head;
			for (unsigned i = fifo->list_size; i > 0; i--) {
				if (tmp_pg->page_num == tmp_page_num) {
					flag = 1;
					if(is_write)
					    tmp_pg->dirty = 1;
					break;
				}
				tmp_pg = tmp_pg->rlink;
			}
		}
		// 没有该页面 
		if (flag == 0) {
			Page pg = (Page)malloc(sizeof(pageNode));
			pg->llink = NULL;
			pg->rlink = NULL;
			pg->page_num = tmp_page_num;
			if(is_write)
				pg->dirty = 1;

			pg->first = (Addr)malloc(sizeof(addr));
			pg->first->head = offset;
			pg->first->tail = offset + tmp_size - 1;
			pg->first->next = NULL;

			if (fifo->list_size < CAPACITY) {
				listInsert(fifo, pg);
			}
			else {
				listDelete(fifo, fp);
				listInsert(fifo, pg);
			}
		}
		if (flag == 1) {
			// 合并页面中访问的片段 
			insert(tmp_pg, offset, tmp_size);
		}
	}
}

int main(int argc, char* argv[])
{
	FILE* trace;
	trace = fopen(argv[1], "r");
	if (!trace)
		printf("Unable open the file!\n");
	FILE* fp;
	fp = fopen(argv[2], "w");
	if (!fp)
		printf("Unable open the file!\n");

	Cache cache = (Cache)malloc(sizeof(FIFOList) * (INDEX + 1));
	for (int i = 0; i < INDEX + 1; i++) {
		cache[i] = (FIFOList)malloc(sizeof(fifoList));
		cache[i]->list_size = 0;
	}

	double line = 0;
	unsigned long long pre_page = 0;
	char c = ' ';
	int dirty = 0;
	while (1) {
		unsigned long long tmp_num = 0, tmp_group = 0, tmp_page = 0; // 地址，组号，页面号
		unsigned tmp_size = 0, offset = 0; 			 // 数据量，页内偏移量 
		dirty = 0;

		if (fscanf(trace, "%c %llx %u\n", &c, &tmp_num, &tmp_size) == EOF) {
			break;
		}

		if(c == 'W')
			dirty = 1;

		tmp_page = tmp_num / (SUBPAGE + 0x1);
		tmp_group = (tmp_num / (SUBPAGE + 0x1)) % INDEX;
		offset = tmp_num & SUBPAGE;

		// printf("%lf\n", ++line);
		++line;
		// if((int)line > 1450000000)
		//	break;

		if (offset + tmp_size - 1 <= SUBPAGE) {
			createPage(cache[tmp_group], tmp_page, offset, tmp_size, fp, dirty);
			if (tmp_page != pre_page) {
				access++;
				pre_page = tmp_page;
			}
		}
		// 偏移量 + 数据量 - 1 > SUBPAGE   :超出当前页 
		else {
			createPage(cache[tmp_group], tmp_page, offset, SUBPAGE - offset + 1, fp, dirty);
			if (tmp_page != pre_page) {
				access++;
				pre_page = tmp_page;
			}
			tmp_page = tmp_page + 1;
			tmp_size = tmp_size - (SUBPAGE - offset + 1);
			tmp_group = tmp_page % INDEX;
			while (tmp_size > 0) {
				if (tmp_size >= (SUBPAGE + 1)) {
					createPage(cache[tmp_group], tmp_page, 0, SUBPAGE + 1, fp, dirty);
					if (tmp_page != pre_page) {
						access++;
						pre_page = tmp_page;
					}
					tmp_page = tmp_page + 1;
					tmp_size = tmp_size - (SUBPAGE - 0 + 1);
					tmp_group = tmp_page % INDEX;
				}
				else
				{
					createPage(cache[tmp_group], tmp_page, 0, tmp_size, fp, dirty);
					if (tmp_page != pre_page) {
						access++;
						pre_page = tmp_page;
					}
					break;
				}
			}
		}
	}


	// 输出缓存中的剩余页面
	for (int i = 0; i < INDEX + 1; i++) {
		//printf("输出第%d组：\n", i);
		// 输出list中剩余页面 
		while (cache[i]->list_size) {
			listDelete(cache[i], fp);
		}
		free(cache[i]);
	}
	free(cache);

	fprintf(fp, "#page_access: %llu\n", access);
	fprintf(fp, "#write_back: %llu\n", write_back);

	fclose(fp);
	fclose(trace);

	return 0;
}
