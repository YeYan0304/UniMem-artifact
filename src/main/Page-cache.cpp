﻿#include <stdio.h>
#include <malloc.h>

#define CAPACITY 389
// size of inactive_list = (CAPACITY + 1) / 2
// size of active_list = CAPACITY / 2
#define SUBPAGE 0xfff
#define INDEX 0x0

unsigned long long active_hit = 0, inactive_hit = 0;
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
typedef struct lruList {
	Page active_head;
	Page active_tail;
	Page inactive_head;
	Page inactive_tail;
	unsigned active_size;
	unsigned inactive_size;
}*LRUList, ** Cache;

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
		while (tmp->next && tmp->tail >= tmp->next->head - 1) {
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
	//printf("出队并输出   %llx %u\n", p->page_num, p->dirty);
	fprintf(fp, "%llx %u\n", p->page_num, size);
	if(p->dirty)
		write_back++;
}

// 将页面pg 插入 active队首 
void activeInsert(LRUList lru, Page pg)
{
	if (lru->active_size == 0)
	{
		pg->llink = NULL;
		pg->rlink = NULL;
		lru->active_head = pg;
		lru->active_tail = pg;
		lru->active_size = 1;
		return;
	}
	Page tmp_pg = lru->active_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	lru->active_head = pg;
	lru->active_size += 1;
}
// 删除 active队尾页面 
Page activeDelete(LRUList lru)
{
	Page tmp_pg = lru->active_tail;
	if (tmp_pg->llink) {
		tmp_pg->llink->rlink = NULL;
		lru->active_tail = tmp_pg->llink;
	}
	else {
		lru->active_head = NULL;
		lru->active_tail = NULL;
	}
	lru->active_size -= 1;
	return tmp_pg;
}
// 将页面 pg 插入 inactive队首 
void inactiveInsert(LRUList lru, Page pg)
{
	if (lru->inactive_size == 0) {
		pg->llink = NULL;
		pg->rlink = NULL;
		lru->inactive_head = pg;
		lru->inactive_tail = pg;
		lru->inactive_size = 1;
		return;
	}
	Page tmp_pg = lru->inactive_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	lru->inactive_head = pg;
	lru->inactive_size += 1;
}
// 删除 inactive队尾页面  并输出 
void inactiveDelete(LRUList lru, FILE* fp)
{
	Page tmp_pg = lru->inactive_tail;
	if (tmp_pg->llink)
	{
		tmp_pg->llink->rlink = NULL;
		lru->inactive_tail = tmp_pg->llink;
	}
	else {
		lru->inactive_head = NULL;
		lru->inactive_tail = NULL;
	}
	lru->inactive_size -= 1;

	PrintSize(tmp_pg, fp);
	free(tmp_pg);
}

int createPage(LRUList lru, unsigned long long tmp_page_num, unsigned offset, unsigned tmp_size, FILE* fp, int is_write)
{
	int flag = 0;

	if (lru->active_size == 0 && lru->inactive_size == 0)
	{
		Page pg = (Page)malloc(sizeof(pageNode));
		pg->llink = NULL;
		pg->rlink = NULL;
		pg->page_num = tmp_page_num;
		pg->first = (Addr)malloc(sizeof(addr));
		pg->first->head = offset;
		pg->first->tail = offset + tmp_size - 1;
		pg->first->next = NULL;
		if(is_write)
			pg->dirty = 1;
		lru->inactive_head = pg;
		lru->inactive_tail = pg;
		lru->inactive_size = 1;
	}
	else {
		Page tmp_pg = NULL;
		// active非空 则在 active 队中查找 
		if (lru->active_size != 0) {
			tmp_pg = lru->active_head;
			for (unsigned i = lru->active_size; i > 0; i--) {
				if (tmp_pg->page_num == tmp_page_num) {
					flag = 2;
					break;
				}
				tmp_pg = tmp_pg->rlink;
			}
		}
		// active 队中没有且inactive非空  则在inacive中查找 
		if (flag == 0 && lru->inactive_size != 0) {
			tmp_pg = lru->inactive_head;
			for (unsigned i = lru->inactive_size; i > 0; i--) {
				if (tmp_pg->page_num == tmp_page_num) {
					flag = 1;
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
			pg->first = (Addr)malloc(sizeof(addr));
			pg->first->head = offset;
			pg->first->tail = offset + tmp_size - 1;
			pg->first->next = NULL;
			if(is_write)
				pg->dirty = 1;

			if (lru->inactive_size < CAPACITY - lru->active_size + 1) {
				inactiveInsert(lru, pg);
			}
			else {
				inactiveDelete(lru, fp);
				inactiveInsert(lru, pg);
			}
		}
		// 该页面在 inactive队中  将页面提升到 active队 
		if (flag == 1) {
			// 合并页面中访问的片段 
			insert(tmp_pg, offset, tmp_size);
			if(is_write)
				tmp_pg->dirty = 1;

			if (tmp_pg->llink == NULL) {
				// 该页面为 inactive中第一个且为最后一个 
				if (tmp_pg->rlink == NULL) {
					lru->inactive_head = NULL;
					lru->inactive_tail = NULL;
					lru->inactive_size -= 1;
				}
				// 该页面为 inactive中第一个
				else {
					lru->inactive_head = tmp_pg->rlink;
					tmp_pg->rlink->llink = tmp_pg->llink;
					lru->inactive_size -= 1;
				}
			}
			else {
				// 该页面为 inactive中最后一个
				if (tmp_pg->rlink == NULL) {
					lru->inactive_tail = tmp_pg->llink;
					tmp_pg->llink->rlink = tmp_pg->rlink;
					lru->inactive_size -= 1;
				}
				// 非第一个 且 非最后一个 
				else {
					tmp_pg->llink->rlink = tmp_pg->rlink;
					tmp_pg->rlink->llink = tmp_pg->llink;
					lru->inactive_size -= 1;
				}
			}
			if (lru->active_size < lru->inactive_size + 1) {
				activeInsert(lru, tmp_pg);
			}
			// active_size == CAPACITY / 2   active队中页面满   
			else {
				Page pg = activeDelete(lru);
				inactiveInsert(lru, pg);
				activeInsert(lru, tmp_pg);
			}
		}
		// 该页面在 active队中 
		if (flag == 2) {
			// 合并页面中访问的片段 
			insert(tmp_pg, offset, tmp_size);
			if(is_write)
				tmp_pg->dirty = 1;
			// 已经是队首 
			if (tmp_pg->llink == NULL) {
				;
			}
			// 位于 active队尾 
			else if (tmp_pg->rlink == NULL) {
				lru->active_tail = tmp_pg->llink;
				tmp_pg->llink->rlink = NULL;
				lru->active_size -= 1;
				activeInsert(lru, tmp_pg);
			}
			// 位于 active队中间 
			else {
				tmp_pg->llink->rlink = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				lru->active_size -= 1;
				activeInsert(lru, tmp_pg);
			}
		}
	}

	return flag;
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

	Cache cache = (Cache)malloc(sizeof(LRUList) * (INDEX + 1));
	for (int i = 0; i < INDEX + 1; i++) {
		cache[i] = (LRUList)malloc(sizeof(lruList));
		cache[i]->active_size = 0;
		cache[i]->inactive_size = 0;
	}

	double line = 0;
	int flag = 0;
	char c = ' ';
	int dirty = 0;
	while (1) {
		unsigned long long tmp_num = 0, tmp_group = 0, tmp_page = 0; // 地址，组号，页面号
		unsigned tmp_size = 0, offset = 0; 			 // 数据量，页内偏移量 
		dirty = 0;

		if (fscanf(trace, "%c %llx %u\n", &c, &tmp_num, &tmp_size) == EOF) {
			break;
		}

		if(c == 'W'){
			dirty = 1;
			//printf("#\n");
		}
		tmp_page = tmp_num / (SUBPAGE + 0x1);
		tmp_group = (tmp_num / (SUBPAGE + 0x1)) & INDEX;
		offset = tmp_num & SUBPAGE;

		// printf("%lf\n", ++line);
		++line;
		// if((int)line > 1450000000)
		//	break;

		if (offset + tmp_size - 1 <= SUBPAGE) {
			flag = createPage(cache[tmp_group], tmp_page, offset, tmp_size, fp, dirty);
			access++;
			if (flag == 2) {
				active_hit++ ;
			}
			else if (flag == 1) {
				inactive_hit++;
			}
		}
		// 偏移量 + 数据量 - 1 > SUBPAGE   :超出当前页 
		else {
			flag = createPage(cache[tmp_group], tmp_page, offset, SUBPAGE - offset + 1, fp, dirty);
			access++;
			if (flag == 2) {
				active_hit++;
			}
			else if (flag == 1) {
				inactive_hit++;
			}
			tmp_page = tmp_page + 1;
			tmp_size = tmp_size - (SUBPAGE - offset + 1);
			tmp_group = tmp_page & INDEX;
			while (tmp_size > 0) {
				if (tmp_size >= (SUBPAGE + 1)) {
					flag = createPage(cache[tmp_group], tmp_page, 0, SUBPAGE + 1, fp, dirty);
					access++;
					if (flag == 2) {
						active_hit++;
					}
					else if (flag == 1) {
						inactive_hit++;
					}
					tmp_page = tmp_page + 1;
					tmp_size = tmp_size - (SUBPAGE - 0 + 1);
					tmp_group = tmp_page & INDEX;
				}
				else
				{
					flag = createPage(cache[tmp_group], tmp_page, 0, tmp_size, fp, dirty);
					access++;
					if (flag == 2) {
						active_hit++;
					}
					else if (flag == 1) {
						inactive_hit++;
					}
					break;
				}
			}
		}
	}
	unsigned active_size = cache[0]->active_size;
	unsigned inactive_size = cache[0]->inactive_size;

	// 输出缓存中的剩余页面
	for (int i = 0; i < INDEX + 1; i++) {
		//printf("输出第%d组：\n", i);
		// 输出inactive中剩余页面 
		while (cache[i]->inactive_size) {
			inactiveDelete(cache[i], fp);
		}
		// 输出active中剩余页面 
		while (cache[i]->active_size) {
			Page pg = activeDelete(cache[i]);
			PrintSize(pg, fp);
			free(pg);
		}
		free(cache[i]);
	}
	free(cache);

	fprintf(fp, "#active_size: %u \n", active_size);
	fprintf(fp, "#inactive_size: %u \n", inactive_size);
	fprintf(fp, "#page_access: %llu\n", access);
	fprintf(fp, "#active_hit:  %llu \n", active_hit);
	fprintf(fp, "#inactive_hit:  %llu \n", inactive_hit);
	fprintf(fp, "#write_back:  %llu \n", write_back);

	fclose(fp);
	fclose(trace);

	return 0;
}
