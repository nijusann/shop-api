--
-- PostgreSQL database dump
--

\restrict te3otfU8mJ0DH8qxwBBWZyfGGkihjNaRWFdkcGTB5rycgg4td1ywadxyUibFjay

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-09-05 19:05:00

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 16608)
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    category_id integer NOT NULL,
    name text NOT NULL,
    parent_id integer,
    level integer
);


ALTER TABLE public.category OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16607)
-- Name: category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.category_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.category_category_id_seq OWNER TO postgres;

--
-- TOC entry 4903 (class 0 OID 0)
-- Dependencies: 217
-- Name: category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.category_category_id_seq OWNED BY public.category.category_id;


--
-- TOC entry 222 (class 1259 OID 16637)
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    client_id integer NOT NULL,
    name text NOT NULL,
    address text
);


ALTER TABLE public.client OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16636)
-- Name: client_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.client_client_id_seq OWNER TO postgres;

--
-- TOC entry 4904 (class 0 OID 0)
-- Dependencies: 221
-- Name: client_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_client_id_seq OWNED BY public.client.client_id;


--
-- TOC entry 226 (class 1259 OID 16663)
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    order_item_id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16662)
-- Name: order_item_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_item_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_item_order_item_id_seq OWNER TO postgres;

--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_item_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_item_order_item_id_seq OWNED BY public.order_item.order_item_id;


--
-- TOC entry 224 (class 1259 OID 16647)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    client_id integer,
    order_date timestamp without time zone DEFAULT now(),
    status text DEFAULT 'pending'::text
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16646)
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- TOC entry 220 (class 1259 OID 16622)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    product_id integer NOT NULL,
    name text NOT NULL,
    price numeric(10,2) NOT NULL,
    quantity integer DEFAULT 0,
    category_id integer
);


ALTER TABLE public.product OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16621)
-- Name: product_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_product_id_seq OWNER TO postgres;

--
-- TOC entry 4907 (class 0 OID 0)
-- Dependencies: 219
-- Name: product_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_product_id_seq OWNED BY public.product.product_id;


--
-- TOC entry 227 (class 1259 OID 24580)
-- Name: top_5_best_selling_products_last_month; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.top_5_best_selling_products_last_month AS
 WITH RECURSIVE category_tree AS (
         SELECT category.category_id,
            category.name AS category_name,
            category.parent_id,
            category.level,
            category.category_id AS root_id,
            category.name AS root_name
           FROM public.category
          WHERE (category.parent_id IS NULL)
        UNION ALL
         SELECT c.category_id,
            c.name,
            c.parent_id,
            c.level,
            ct_1.root_id,
            ct_1.root_name
           FROM (public.category c
             JOIN category_tree ct_1 ON ((c.parent_id = ct_1.category_id)))
        )
 SELECT p.name AS "Наименование товара",
    ct.root_name AS "Категория 1-го уровня",
    sum(oi.quantity) AS "Общее количество проданных штук"
   FROM (((public.order_item oi
     JOIN public.orders o ON ((oi.order_id = o.order_id)))
     JOIN public.product p ON ((oi.product_id = p.product_id)))
     JOIN category_tree ct ON ((p.category_id = ct.category_id)))
  WHERE (o.order_date >= (CURRENT_DATE - '1 mon'::interval))
  GROUP BY p.name, ct.root_name
  ORDER BY (sum(oi.quantity)) DESC
 LIMIT 5;


ALTER VIEW public.top_5_best_selling_products_last_month OWNER TO postgres;

--
-- TOC entry 4719 (class 2604 OID 16611)
-- Name: category category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category ALTER COLUMN category_id SET DEFAULT nextval('public.category_category_id_seq'::regclass);


--
-- TOC entry 4722 (class 2604 OID 16640)
-- Name: client client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client ALTER COLUMN client_id SET DEFAULT nextval('public.client_client_id_seq'::regclass);


--
-- TOC entry 4726 (class 2604 OID 16666)
-- Name: order_item order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_item_order_item_id_seq'::regclass);


--
-- TOC entry 4723 (class 2604 OID 16650)
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- TOC entry 4720 (class 2604 OID 16625)
-- Name: product product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN product_id SET DEFAULT nextval('public.product_product_id_seq'::regclass);


--
-- TOC entry 4889 (class 0 OID 16608)
-- Dependencies: 218
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category (category_id, name, parent_id, level) FROM stdin;
1	Компьютеры и компьютерная техника	\N	1
2	Компьютеры	1	2
3	Компьютерные комплектующие	1	2
4	Настольные	2	3
5	Ноутбуки	2	3
6	Моноблоки	2	3
13	Десктопные процессоры	10	4
14	Серверные процессоры	10	4
15	Смартфоны	\N	1
16	Планшеты	\N	1
17	Обычные планшеты	16	2
18	Планшеты-трансформеры	16	2
10	Процессоры	3	3
11	Оперативная память	3	3
12	Видеокарты	3	3
7	Обычные ноутбуки	5	4
8	Ультрабуки	5	4
9	Игровые ноутбуки	5	4
\.


--
-- TOC entry 4893 (class 0 OID 16637)
-- Dependencies: 222
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.client (client_id, name, address) FROM stdin;
1	Иван Петров	г. Москва, ул. Ленина, д. 10, кв. 5
2	Мария Сидорова	г. Санкт-Петербург, Невский проспект, д. 25, кв. 12
3	Алексей Кузнецов	г. Екатеринбург, ул. Мира, д. 7, кв. 33
4	Елена Волкова	г. Казань, ул. Баумана, д. 14, кв. 8
5	Дмитрий Орлов	г. Новосибирск, ул. Гоголя, д. 45, кв. 21
6	Анна Фролова	г. Самара, ул. Чапаева, д. 19, кв. 4
7	Сергей Морозов	г. Омск, ул. Лермонтова, д. 30, кв. 17
8	Наталья Васильева	г. Ростов-на-Дону, ул. Пушкинская, д. 12, кв. 29
9	Павел Николаев	г. Уфа, ул. Карла Маркса, д. 50, кв. 6
10	Ольга Лебедева	г. Красноярск, ул. 9 Мая, д. 22, кв. 34
11	Артём Семёнов	г. Пермь, ул. Комсомольский проспект, д. 11, кв. 10
12	Татьяна Крылова	г. Воронеж, ул. 20 лет Октября, д. 8, кв. 15
13	Виктор Ширяев	г. Саратов, ул. Радищева, д. 33, кв. 7
14	Юлия Зимина	г. Тюмень, ул. Республики, д. 18, кв. 24
15	Игорь Белов	г. Иркутск, ул. Ленина, д. 40, кв. 11
16	Ксения Григорьева	г. Хабаровск, ул. Дикопольцева, д. 6, кв. 3
17	Роман Павлов	г. Барнаул, ул. Короленко, д. 27, кв. 19
18	Анастасия Миронова	г. Ярославль, ул. Свободы, д. 13, кв. 31
19	Григорий Лазарев	г. Владивосток, ул. Светланская, д. 21, кв. 9
20	Дарья Егорова	г. Калининград, ул. Черняховского, д. 35, кв. 2
22	Екатерина Зотова	г. Санкт-Петербург, ул. Невский проспект, д. 40, кв. 6
23	Максим Фай	г. Екатеринбург, ул. Мира, д. 35, кв. 68
24	Ольга Зимина	г. Казань, ул. Баумана, д. 36, кв. 40
25	Иван Иванов	г. Новосибирск, ул. Гоголя, д. 43, кв. 75
27	Сергей Субботин	г. Омск, ул. Лермонтова, д. 15, кв. 22
28	Наталья Митина	г. Ростов-на-Дону, ул. Пушкинская, д. 49, кв. 73
29	Дмитрий Погорелов	г. Уфа, ул. Карла Маркса, д. 38, кв. 73
30	Алина Ахматова	г. Красноярск, ул. 9 Мая, д. 28, кв. 54
32	Юлия Описова	г. Воронеж, ул. 20 лет Октября, д. 27, кв. 8
33	Павел Грин	г. Саратов, ул. Радищева, д. 11, кв. 16
34	Дарья Белова	г. Тюмень, ул. Республики, д. 19, кв. 7
35	Роман Атбеков	г. Иркутск, ул. Ленина, д. 23, кв. 77
36	Ксения Щербакова	г. Хабаровск, ул. Дикопольцева, д. 32, кв. 27
37	Григорий Рокоссовский	г. Барнаул, ул. Короленко, д. 47, кв. 73
38	Анастасия Заболотная	г. Ярославль, ул. Свободы, д. 43, кв. 100
40	Людмила Прокшина	г. Калининград, ул. Черняховского, д. 37, кв. 76
41	Андрей Львов	г. Москва, ул. Ленина, д. 41, кв. 34
42	Екатерина Шиманова	г. Санкт-Петербург, ул. Невский проспект, д. 36, кв. 80
43	Михаил Ломов	г. Екатеринбург, ул. Мира, д. 30, кв. 15
44	Олег Заменгоф	г. Казань, ул. Баумана, д. 7, кв. 37
45	Ильхам Умеров	г. Новосибирск, ул. Гоголя, д. 39, кв. 47
46	Дарий Пьянич	г. Самара, ул. Чапаева, д. 38, кв. 55
48	Нина Кукушкина	г. Ростов-на-Дону, ул. Пушкинская, д. 47, кв. 72
49	Дмитрий Сотов	г. Уфа, ул. Карла Маркса, д. 34, кв. 44
50	Яна Пенина	г. Красноярск, ул. 9 Мая, д. 31, кв. 27
51	Григорий Плющев	г. Пермь, ул. Комсомольский проспект, д. 29, кв. 73
52	Анна Корнеева	г. Воронеж, ул. 20 лет Октября, д. 51, кв. 74
54	Дарья Лазарь	г. Тюмень, ул. Республики, д. 28, кв. 35
55	Тарас Кепкин	г. Иркутск, ул. Ленина, д. 50, кв. 63
56	Оксана Попко	г. Хабаровск, ул. Дикопольцева, д. 39, кв. 58
57	Борис Ванин	г. Барнаул, ул. Короленко, д. 43, кв. 38
58	Анастасия Чернова	г. Ярославль, ул. Свободы, д. 23, кв. 94
59	Виктор Чернов	г. Ярославль, ул. Свободы, д. 23, кв. 94
61	Андрей Видяев	г. Москва, ул. Ленина, д. 44, кв. 44
62	Алсу Габдуллина	г. Санкт-Петербург, ул. Невский проспект, д. 41, кв. 56
63	Максим Пивоваров	г. Екатеринбург, ул. Мира, д. 13, кв. 59
64	Евгения Царева	г. Казань, ул. Баумана, д. 5, кв. 26
65	Иван Прохоров	г. Новосибирск, ул. Гоголя, д. 5, кв. 77
66	Татьяна Дубровина	г. Самара, ул. Чапаева, д. 49, кв. 30
67	Сергей Романов	г. Омск, ул. Лермонтова, д. 19, кв. 69
71	Руслан Васильев	г. Пермь, ул. Комсомольский проспект, д. 6, кв. 57
72	Никита Мосенов	г. Воронеж, ул. 20 лет Октября, д. 1, кв. 28
73	Павел Петров	г. Саратов, ул. Радищева, д. 15, кв. 76
74	Дарья Панфилова	г. Тюмень, ул. Республики, д. 36, кв. 10
75	Владимир Тишин	г. Иркутск, ул. Ленина, д. 44, кв. 57
77	Алексей Говин	г. Барнаул, ул. Короленко, д. 13, кв. 24
78	Анна Зверева	г. Ярославль, ул. Свободы, д. 50, кв. 67
79	Антон Чуприн	г. Владивосток, ул. Светланская, д. 47, кв. 5
80	Лидия Беспалова	г. Калининград, ул. Черняховского, д. 8, кв. 82
81	Андрей Станиславский	г. Москва, ул. Ленина, д. 47, кв. 32
83	Евгений Хромов	г. Екатеринбург, ул. Мира, д. 13, кв. 74
84	Роман Бусыгин	г. Казань, ул. Баумана, д. 32, кв. 23
85	Иван Игнатьев	г. Новосибирск, ул. Гоголя, д. 15, кв. 33
86	Степан Шавараков	г. Самара, ул. Чапаева, д. 20, кв. 9
87	Сергей Юсаев	г. Омск, ул. Лермонтова, д. 36, кв. 91
88	Надежда Саитгареева	г. Ростов-на-Дону, ул. Пушкинская, д. 46, кв. 93
89	Дмитрий Собчинский	г. Уфа, ул. Карла Маркса, д. 35, кв. 18
90	Антон Кисибокин	г. Красноярск, ул. 9 Мая, д. 21, кв. 19
92	Юлия Солодко	г. Воронеж, ул. 20 лет Октября, д. 13, кв. 18
93	Артемий Сидоров	г. Саратов, ул. Радищева, д. 27, кв. 29
94	Дарья Алексеева	г. Тюмень, ул. Республики, д. 24, кв. 40
95	Роман Фомин	г. Иркутск, ул. Ленина, д. 8, кв. 85
96	Дмитрий Пинаков	г. Хабаровск, ул. Дикопольцева, д. 11, кв. 95
97	Григорий Русин	г. Барнаул, ул. Короленко, д. 37, кв. 63
98	Маша Гаркуша	г. Ярославль, ул. Свободы, д. 19, кв. 54
100	Никита Большаков	г. Калининград, ул. Черняховского, д. 47, кв. 46
101	Андрей Толмачев	г. Москва, ул. Ленина, д. 50, кв. 69
102	Екатерина Кобулова	г. Санкт-Петербург, ул. Невский проспект, д. 42, кв. 98
103	Кирилл Шлобин	г. Екатеринбург, ул. Мира, д. 44, кв. 100
104	Ислам Саябуддинов	г. Казань, ул. Баумана, д. 27, кв. 6
106	Тамара Изюмская	г. Самара, ул. Чапаева, д. 24, кв. 98
107	Сергей Соколов	г. Омск, ул. Лермонтова, д. 48, кв. 11
108	Наталья Клюкина	г. Ростов-на-Дону, ул. Пушкинская, д. 34, кв. 2
109	Дмитрий Кузнецов	г. Уфа, ул. Карла Маркса, д. 10, кв. 40
110	Анна Волобуева	г. Красноярск, ул. 9 Мая, д. 23, кв. 95
112	Юлия Швыдкина	г. Воронеж, ул. 20 лет Октября, д. 32, кв. 99
113	Евгений Соловьев	г. Саратов, ул. Радищева, д. 26, кв. 57
114	Марина Вязовцева	г. Тюмень, ул. Республики, д. 9, кв. 53
115	Роман Дураков	г. Иркутск, ул. Ленина, д. 50, кв. 28
116	Динар Зубаиров	г. Хабаровск, ул. Дикопольцева, д. 35, кв. 36
117	Сергей Тулаев	г. Барнаул, ул. Короленко, д. 3, кв. 76
119	Александра Мараховкина	г. Владивосток, ул. Светланская, д. 8, кв. 86
120	Сергей Шмаков	г. Калининград, ул. Черняховского, д. 33, кв. 13
121	Вадим Руденко	г. Москва, ул. Ленина, д. 28, кв. 74
122	Мария Руденко	г. Москва, ул. Ленина, д. 28, кв. 74
123	Максим Якуш	г. Екатеринбург, ул. Мира, д. 16, кв. 41
124	Константин Янзытов	г. Казань, ул. Баумана, д. 27, кв. 25
125	Сергей Бубнов	г. Новосибирск, ул. Гоголя, д. 21, кв. 87
126	Татьяна Нефедова	г. Самара, ул. Чапаева, д. 6, кв. 74
128	Анна Безрадная	г. Ростов-на-Дону, ул. Пушкинская, д. 35, кв. 17
129	Дмитрий Пономарев	г. Уфа, ул. Карла Маркса, д. 36, кв. 32
130	Анна Тростина	г. Красноярск, ул. 9 Мая, д. 21, кв. 20
131	Артём Павлов	г. Пермь, ул. Комсомольский проспект, д. 26, кв. 16
133	Павел Сергиев	г. Саратов, ул. Радищева, д. 42, кв. 94
134	Александр Тиньков	г. Тюмень, ул. Республики, д. 12, кв. 21
135	Роман Лунькин	г. Иркутск, ул. Ленина, д. 48, кв. 47
136	Арсений Кудряшов	г. Хабаровск, ул. Дикопольцева, д. 7, кв. 52
137	Александр Сартаков	г. Барнаул, ул. Короленко, д. 5, кв. 62
138	Елена Фиошкина	г. Ярославль, ул. Свободы, д. 2, кв. 58
21	Андрей Зинченко	г. Москва, ул. Ленина, д. 27, кв. 98
26	Татьяна Савчук	г. Самара, ул. Чапаева, д. 44, кв. 70
31	Артём Начкебия	г. Пермь, ул. Комсомольский проспект, д. 39, кв. 32
39	Виктор Серов	г. Владивосток, ул. Светланская, д. 4, кв. 30
47	Семен Клюев	г. Омск, ул. Лермонтова, д. 33, кв. 92
53	Тигран Джигарханян	г. Саратов, ул. Радищева, д. 20, кв. 48
60	Людмила Лебединская	г. Калининград, ул. Черняховского, д. 37, кв. 12
68	Нина Козак	г. Ростов-на-Дону, ул. Пушкинская, д. 41, кв. 54
69	Дмитрий Щипило	г. Уфа, ул. Карла Маркса, д. 18, кв. 82
70	Арина Асадуллина	г. Красноярск, ул. 9 Мая, д. 13, кв. 53
76	Александр Григорьев	г. Хабаровск, ул. Дикопольцева, д. 4, кв. 52
82	Елена Абакумова	г. Санкт-Петербург, ул. Невский проспект, д. 9, кв. 61
91	Елена Москвичева	г. Пермь, ул. Комсомольский проспект, д. 33, кв. 92
99	Михаил Долгов	г. Владивосток, ул. Светланская, д. 8, кв. 12
105	Дмитрий Цивилев	г. Новосибирск, ул. Гоголя, д. 28, кв. 78
111	Артём Баранов	г. Пермь, ул. Комсомольский проспект, д. 22, кв. 65
118	Анастасия Бабиева	г. Ярославль, ул. Свободы, д. 8, кв. 11
127	Алексей Балашов	г. Омск, ул. Лермонтова, д. 49, кв. 89
132	Алла Резанова	г. Воронеж, ул. 20 лет Октября, д. 31, кв. 99
139	Ян Агаст	г. Владивосток, ул. Светланская, д. 48, кв. 48
140	Александр Каравайко	г. Калининград, ул. Черняховского, д. 8, кв. 13
141	Евгений Пашков	г. Москва, ул. Ленина, д. 15, кв. 11
142	Марат Караев	г. Санкт-Петербург, ул. Невский проспект, д. 23, кв. 81
143	Александр Гурин	г. Екатеринбург, ул. Мира, д. 7, кв. 98
144	Олеся Подорванова	г. Казань, ул. Баумана, д. 49, кв. 97
145	Надежда Бравина	г. Новосибирск, ул. Гоголя, д. 8, кв. 21
146	Тимофей Демин	г. Самара, ул. Чапаева, д. 8, кв. 55
147	Степан Филлипов	г. Омск, ул. Лермонтова, д. 7, кв. 53
148	Александр Владимиров	г. Ростов-на-Дону, ул. Пушкинская, д. 42, кв. 32
149	Юрий Киров	г. Уфа, ул. Карла Маркса, д. 47, кв. 55
150	Илья Потриваев	г. Красноярск, ул. 9 Мая, д. 23, кв. 87
151	Богдан Русов	г. Пермь, ул. Комсомольский проспект, д. 11, кв. 70
152	Владимир Ивашкин	г. Воронеж, ул. 20 лет Октября, д. 48, кв. 96
153	Святослав Харитонов	г. Саратов, ул. Радищева, д. 15, кв. 7
154	Анастасия Курпат	г. Тюмень, ул. Республики, д. 22, кв. 22
155	Антон Новиков	г. Иркутск, ул. Ленина, д. 12, кв. 30
156	Кирилл Огольцов	г. Хабаровск, ул. Дикопольцева, д. 11, кв. 21
157	Сергей Кушнир	г. Барнаул, ул. Короленко, д. 5, кв. 53
158	Анастасия Лебедева	г. Ярославль, ул. Свободы, д. 44, кв. 91
159	Виктор Рысев	г. Владивосток, ул. Светланская, д. 9, кв. 49
160	Сергей Жуков	г. Калининград, ул. Черняховского, д. 47, кв. 75
161	Алексей Шавмаров	г. Киров, ул. Советская, д. 2, кв. 2
162	Павел Таюрский	г. Новосибирск, ул. Пешеходная, д. 3, кв. 1
163	Сергей Кирюшинов	г. Салехард, ул. Пионерская, д. 1
164	Юлия Стрижкова	г. Мурманск, ул. Полярные Зори, д. 10, кв. 37
165	Андрей Гришнак	г. Астрахань, ул. Комсомольская, д. 11
166	Вероника Феленкова	г. Таганрог, ул. Шевченко, д. 7
167	Александр Вакулин	г. Люберцы, ул. Комсомольский проспект, д. 15, кв. 80
168	Александр Клещенко	г. Мытищи, ул. Рождественская , д. 11, кв. 159
169	Тимур Воробьев	г. Пушкин, ул. Пушкинская, д. 46, кв. 10
170	Андрей Исаев	г. Петропавловск-Камчатский, ул. Набережная, д. 10, кв. 4
171	Борис Борисов	г. Королев, ул. Терешковой, д. 1, кв. 1
172	Александра Александрова	г. Магадан, ул. Советская, д. 23, кв. 30
\.


--
-- TOC entry 4897 (class 0 OID 16663)
-- Dependencies: 226
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_item (order_item_id, order_id, product_id, quantity, unit_price) FROM stdin;
1	1	3	1	89990.00
2	1	7	1	67000.00
3	2	19	1	45000.00
4	3	6	1	145000.00
5	4	5	1	92000.00
6	4	14	2	6000.00
7	5	9	1	24000.00
8	5	16	1	180000.00
9	6	1	2	60000.00
10	7	8	1	72000.00
11	7	15	4	5500.00
12	8	4	1	45000.00
13	9	10	1	15000.00
14	9	11	1	28000.00
15	10	19	1	45000.00
16	10	20	1	85000.00
17	11	17	1	160000.00
18	12	18	1	28000.00
19	12	14	1	6000.00
20	13	12	2	22000.00
21	14	13	1	120000.00
22	15	5	1	92000.00
23	16	4	1	45000.00
24	16	15	2	5500.00
25	17	3	1	89990.00
26	18	2	2	50000.00
27	19	7	1	67000.00
28	19	16	1	180000.00
29	20	19	1	45000.00
30	20	4	1	45000.00
31	59	18	1	28000.00
49	115	18	1	28000.00
50	152	18	1	28000.00
51	105	18	1	28000.00
81	30	18	2	28000.00
97	109	18	2	28000.00
95	41	16	1	180000.00
88	33	18	1	28000.00
99	97	14	1	6000.00
103	167	12	1	22000.00
113	62	10	1	15000.00
118	121	4	2	45000.00
123	135	17	4	160000.00
128	130	6	1	145000.00
129	139	12	1	22000.00
130	84	3	1	89990.00
131	56	4	2	45000.00
132	110	5	4	92000.00
136	58	7	1	67000.00
135	36	18	1	28000.00
137	111	8	1	72000.00
138	94	9	1	24000.00
141	83	10	1	15000.00
142	50	11	1	28000.00
143	128	12	1	22000.00
144	103	13	1	120000.00
145	85	14	2	6000.00
147	55	15	5	5500.00
148	107	16	2	180000.00
149	95	17	1	160000.00
153	47	19	1	45000.00
151	159	18	2	28000.00
154	127	20	1	85000.00
155	46	1	1	60000.00
156	137	1	1	60000.00
32	169	1	1	60000.00
33	53	2	1	50000.00
34	32	3	1	89990.00
35	64	4	1	45000.00
36	138	5	1	92000.00
37	117	6	1	145000.00
38	71	7	1	67000.00
40	52	9	1	24000.00
41	45	10	1	15000.00
42	44	11	1	28000.00
43	54	12	1	22000.00
44	132	13	1	120000.00
45	142	14	1	6000.00
46	133	15	1	5500.00
47	145	16	1	180000.00
48	99	17	1	160000.00
52	34	16	1	180000.00
53	35	14	1	6000.00
54	78	12	1	22000.00
56	80	8	1	72000.00
57	112	6	1	145000.00
58	23	4	1	45000.00
59	149	2	2	50000.00
60	129	1	2	60000.00
61	86	1	2	60000.00
63	75	3	2	89990.00
64	157	2	2	50000.00
65	151	2	2	50000.00
66	82	20	2	85000.00
67	113	19	2	45000.00
68	89	1	2	60000.00
70	158	5	2	92000.00
71	168	7	2	67000.00
72	42	9	2	24000.00
74	120	11	2	28000.00
75	26	15	2	5500.00
76	144	17	2	160000.00
78	100	19	2	45000.00
79	43	13	2	120000.00
80	27	20	2	85000.00
82	122	1	2	60000.00
83	28	4	2	45000.00
84	134	6	2	145000.00
86	106	1	2	60000.00
87	91	3	2	89990.00
89	162	2	2	50000.00
90	119	4	2	45000.00
91	29	6	2	145000.00
92	40	5	2	92000.00
93	70	10	2	15000.00
94	116	13	2	120000.00
96	68	16	2	180000.00
98	21	5	2	92000.00
100	150	15	2	5500.00
101	77	3	2	89990.00
104	143	12	2	22000.00
105	48	7	2	67000.00
106	140	13	2	120000.00
107	101	12	2	22000.00
108	92	2	2	50000.00
109	72	14	2	6000.00
110	170	20	2	85000.00
111	66	19	2	45000.00
112	57	19	2	45000.00
114	31	4	2	45000.00
115	96	14	2	6000.00
116	123	4	2	45000.00
119	118	1	3	60000.00
120	51	1	3	60000.00
121	148	2	3	50000.00
122	93	2	3	50000.00
124	146	2	3	50000.00
125	155	3	3	89990.00
126	124	4	3	45000.00
127	22	2	3	50000.00
134	125	1	3	60000.00
139	24	1	3	60000.00
140	63	3	3	89990.00
146	65	4	3	45000.00
157	126	1	3	60000.00
73	88	6	3	145000.00
175	114	18	1	28000.00
39	156	8	1	72000.00
55	147	10	1	15000.00
69	160	3	2	89990.00
85	69	5	2	92000.00
102	108	13	2	120000.00
117	39	1	3	60000.00
152	38	5	3	92000.00
160	74	17	3	160000.00
163	165	16	3	180000.00
164	37	15	4	5500.00
174	81	14	4	6000.00
180	153	13	4	120000.00
62	49	12	4	22000.00
77	76	11	1	28000.00
133	136	10	2	15000.00
150	161	11	1	28000.00
158	67	9	2	24000.00
159	87	12	1	22000.00
161	166	8	1	72000.00
162	164	13	2	120000.00
165	79	7	1	67000.00
166	90	14	1	6000.00
167	131	6	2	145000.00
168	141	15	2	5500.00
169	163	5	3	92000.00
170	61	16	2	180000.00
171	98	4	3	45000.00
172	154	17	1	160000.00
173	73	3	2	89990.00
176	104	2	1	50000.00
177	60	19	1	45000.00
178	102	1	1	60000.00
179	25	20	5	85000.00
181	1	1	4	60000.00
\.


--
-- TOC entry 4895 (class 0 OID 16647)
-- Dependencies: 224
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, client_id, order_date, status) FROM stdin;
1	1	2025-02-01 10:15:30	confirmed
2	2	2025-02-28 14:22:10	delivered
3	3	2025-03-30 09:45:00	shipped
4	4	2025-04-02 16:30:15	pending
5	5	2025-05-09 11:05:47	confirmed
6	6	2025-05-25 18:10:20	delivered
7	7	2025-05-31 13:55:33	shipped
8	8	2025-06-10 08:00:00	pending
9	9	2025-06-23 12:34:56	confirmed
10	10	2025-07-27 17:19:12	delivered
11	11	2025-07-30 20:01:05	shipped
12	12	2025-08-02 15:40:25	pending
13	13	2025-08-13 10:11:13	confirmed
14	14	2025-08-25 19:30:44	delivered
15	15	2025-08-28 07:20:18	shipped
16	16	2025-08-31 12:00:00	pending
17	17	2025-09-01 16:48:39	confirmed
18	18	2025-09-01 22:15:10	delivered
19	19	2025-09-02 22:27:38.222619	pending
20	20	2025-09-02 22:27:38.222619	pending
21	64	2025-09-03 04:57:40.956864	pending
22	27	2025-09-02 23:15:43.573254	pending
23	124	2025-09-02 18:16:00.818968	pending
24	85	2025-09-02 05:26:46.721638	pending
25	138	2025-09-01 23:57:42.123039	pending
26	127	2025-09-01 23:28:28.956519	pending
27	113	2025-09-01 13:52:03.569623	pending
28	97	2025-09-01 05:55:50.475914	pending
29	26	2025-09-01 03:18:27.429427	pending
30	146	2025-09-01 00:14:31.04752	pending
31	143	2025-08-31 05:40:06.796471	pending
32	75	2025-08-30 19:34:30.341897	pending
33	43	2025-08-30 18:30:59.233034	pending
34	156	2025-08-30 12:42:54.639665	pending
35	25	2025-08-30 09:22:55.584702	pending
36	170	2025-08-30 07:12:28.294847	pending
37	24	2025-08-30 02:05:29.639626	pending
38	169	2025-08-29 18:51:17.658838	pending
39	141	2025-08-29 18:43:01.271949	pending
40	164	2025-08-29 18:40:26.615693	pending
41	73	2025-08-29 15:47:26.025768	pending
42	66	2025-08-29 10:57:02.039912	confirmed
43	122	2025-08-29 06:52:01.193632	confirmed
44	160	2025-08-29 02:31:32.186494	confirmed
45	154	2025-08-28 22:42:58.061124	confirmed
46	53	2025-08-28 20:29:58.006098	confirmed
47	78	2025-08-28 15:15:05.269351	confirmed
48	165	2025-08-28 12:07:46.402252	confirmed
49	136	2025-08-28 11:51:46.279341	confirmed
50	110	2025-08-28 10:33:10.015519	confirmed
51	130	2025-08-28 09:53:20.33046	confirmed
52	103	2025-08-28 06:36:54.678368	confirmed
53	104	2025-08-27 10:32:50.726735	confirmed
54	37	2025-08-27 10:04:57.285178	confirmed
55	114	2025-08-27 08:17:24.517044	confirmed
56	117	2025-08-27 00:02:13.639214	confirmed
57	80	2025-08-26 18:32:03.317732	confirmed
58	90	2025-08-26 15:04:16.615384	confirmed
59	59	2025-08-26 09:24:35.636505	confirmed
60	151	2025-08-26 09:18:57.208859	confirmed
61	44	2025-08-26 04:38:00.605064	confirmed
62	133	2025-08-26 02:54:47.722425	confirmed
63	128	2025-08-26 01:02:24.057286	confirmed
64	51	2025-08-25 15:31:52.716428	confirmed
65	34	2025-08-25 03:47:18.786448	confirmed
66	118	2025-08-25 02:21:11.096733	confirmed
67	28	2025-08-24 19:26:51.408036	confirmed
68	145	2025-08-24 14:47:13.863698	confirmed
69	56	2025-08-24 13:56:18.497859	confirmed
70	98	2025-08-24 12:59:04.115095	confirmed
71	112	2025-08-24 12:12:14.969111	confirmed
72	106	2025-08-24 11:30:28.907018	confirmed
73	40	2025-08-24 11:17:25.684876	confirmed
74	163	2025-08-24 02:16:51.862445	confirmed
75	119	2025-08-23 22:37:08.453062	confirmed
76	152	2025-08-23 05:51:35.422364	confirmed
77	21	2025-08-23 03:13:19.69628	confirmed
78	50	2025-08-23 00:36:06.510828	confirmed
79	57	2025-08-22 20:50:26.590274	confirmed
80	155	2025-08-22 16:55:58.954368	confirmed
81	83	2025-08-22 00:52:07.164387	confirmed
82	68	2025-08-21 20:11:33.662057	confirmed
83	135	2025-08-21 10:49:14.967607	confirmed
84	95	2025-08-20 12:57:06.408176	confirmed
85	150	2025-08-20 11:12:06.484552	confirmed
86	88	2025-08-20 02:09:01.917495	confirmed
87	72	2025-08-19 04:04:03.777183	shipped
88	41	2025-08-18 19:24:26.29571	shipped
89	115	2025-08-18 19:10:58.258491	shipped
90	67	2025-08-18 19:01:19.854051	shipped
91	42	2025-08-18 11:56:05.054867	shipped
92	129	2025-08-18 07:30:59.869291	shipped
93	31	2025-08-18 05:20:29.368648	shipped
94	101	2025-08-18 04:29:51.629629	shipped
95	29	2025-08-18 04:13:28.37166	shipped
96	60	2025-08-18 01:06:11.224404	shipped
97	36	2025-08-17 20:41:49.284977	shipped
98	35	2025-08-17 13:01:13.003044	shipped
99	91	2025-08-17 11:46:03.504158	shipped
100	139	2025-08-17 08:30:06.894836	shipped
101	52	2025-08-17 08:00:51.68414	shipped
102	69	2025-08-17 06:27:53.454703	shipped
103	159	2025-08-17 03:01:00.847775	shipped
104	144	2025-08-16 19:00:16.744638	shipped
105	100	2025-08-16 11:56:03.511665	shipped
106	74	2025-08-16 11:01:28.077137	shipped
107	77	2025-08-16 08:56:46.832786	shipped
108	32	2025-08-16 04:33:02.414651	shipped
109	84	2025-08-15 21:15:43.758046	shipped
110	79	2025-08-15 21:15:28.092076	shipped
111	99	2025-08-15 19:19:19.196233	shipped
112	70	2025-08-15 17:32:41.519976	shipped
113	158	2025-08-15 14:53:49.946924	shipped
114	148	2025-08-15 09:24:07.294309	shipped
115	109	2025-08-15 08:26:41.61067	shipped
116	161	2025-08-14 21:57:31.43231	shipped
117	125	2025-08-14 17:07:36.649245	shipped
118	116	2025-08-14 15:57:33.566466	shipped
119	120	2025-08-14 09:17:29.623995	shipped
120	126	2025-08-14 08:37:27.098037	shipped
121	153	2025-08-14 07:36:06.433533	shipped
122	63	2025-08-14 05:41:32.215463	shipped
123	89	2025-08-14 03:05:35.699817	shipped
124	121	2025-08-13 15:43:43.913583	shipped
125	39	2025-08-13 10:48:28.496544	shipped
126	134	2025-08-13 09:01:57.420173	shipped
127	58	2025-08-12 22:51:52.345679	shipped
128	108	2025-08-12 22:48:22.226274	shipped
129	45	2025-08-12 10:51:10.15686	shipped
130	47	2025-08-12 09:06:46.219175	shipped
131	62	2025-08-12 07:22:46.268408	shipped
132	168	2025-08-12 05:35:51.565552	shipped
133	86	2025-08-12 02:28:13.0658	shipped
134	38	2025-08-12 00:48:47.419814	shipped
135	61	2025-08-11 20:13:33.015093	shipped
136	162	2025-08-11 15:34:52.273738	shipped
137	111	2025-08-11 10:51:53.339272	shipped
138	166	2025-08-11 08:25:26.696014	shipped
139	147	2025-08-10 20:07:50.626913	shipped
140	55	2025-08-10 19:11:16.128044	shipped
141	30	2025-08-10 12:24:19.746063	shipped
142	142	2025-08-10 06:30:04.817773	shipped
143	81	2025-08-10 06:05:31.91356	shipped
144	105	2025-08-09 22:38:39.898075	shipped
145	71	2025-08-09 17:12:44.232072	shipped
146	167	2025-08-09 10:00:02.921765	delivered
147	54	2025-08-09 01:26:52.804835	delivered
148	46	2025-08-08 09:08:18.557461	delivered
149	149	2025-08-08 06:13:10.348755	delivered
150	22	2025-08-07 22:14:01.137456	delivered
151	76	2025-08-07 21:59:40.667755	delivered
152	102	2025-08-07 17:19:39.176969	delivered
153	131	2025-08-07 10:51:42.946852	delivered
154	94	2025-08-06 19:54:56.472801	delivered
155	132	2025-08-06 18:52:35.994241	delivered
156	33	2025-08-06 16:13:41.930525	delivered
157	137	2025-08-06 03:00:11.245997	delivered
158	140	2025-08-06 02:40:19.866353	delivered
159	87	2025-08-05 18:27:30.181123	delivered
160	96	2025-08-05 13:19:19.09913	delivered
161	49	2025-08-05 12:57:10.496535	delivered
162	157	2025-08-05 12:27:47.776163	delivered
163	82	2025-08-05 09:09:54.110557	delivered
164	107	2025-08-05 09:09:47.139355	delivered
165	123	2025-08-05 08:43:58.390523	delivered
166	48	2025-08-05 08:15:08.044966	delivered
167	93	2025-08-05 04:13:53.644167	delivered
168	23	2025-08-05 02:02:25.295196	delivered
169	92	2025-08-04 22:28:49.774211	delivered
170	65	2025-08-04 16:34:06.687534	delivered
\.


--
-- TOC entry 4891 (class 0 OID 16622)
-- Dependencies: 220
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (product_id, name, price, quantity, category_id) FROM stdin;
3	Обычный ноутбук MacBook Air	89990.00	5	7
4	Обычный ноутбук Acer Inspire 14	45000.00	8	7
5	Ультрабук MSI Prestige 14	92000.00	3	8
6	Игровой ноутбук Asus ROG Strix 16	145000.00	4	9
7	Моноблок HP ProOne	67000.00	6	6
8	Моноблок Dell Inspiron	72000.00	7	6
9	Десктопный процессор Intel Core i7-12700K	24000.00	10	13
10	Десктопный процессор Intel Core i5-12400HK	15000.00	15	13
11	Десктопный процессор AMD Ryzen 7 5900X3D	28000.00	8	13
12	Десктопный процессор AMD Ryzen 7 5900X	22000.00	12	13
13	Серверный процессор AMD EPYC 7720	120000.00	2	14
14	Оперативная память Samsung RAM	6000.00	20	11
15	Оперативная память G.Skill Aegis	5500.00	18	11
16	Видеокарта Nvidia GeForce RTX 5080	180000.00	3	12
17	Видеокарта AMD Radeon RX 9700 XT	160000.00	4	12
18	Обычный планшет Xiaomi Mi Pad	28000.00	10	17
19	Обычный планшет iPad Air	45000.00	6	17
20	Планшет трансформер Microsoft Surface	85000.00	5	18
2	Смартфон OnePlus 13T	50000.00	3	15
1	Смартфон iPhone 16	60000.00	29	15
\.


--
-- TOC entry 4908 (class 0 OID 0)
-- Dependencies: 217
-- Name: category_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.category_category_id_seq', 18, true);


--
-- TOC entry 4909 (class 0 OID 0)
-- Dependencies: 221
-- Name: client_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.client_client_id_seq', 172, true);


--
-- TOC entry 4910 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_item_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_item_order_item_id_seq', 181, true);


--
-- TOC entry 4911 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 170, true);


--
-- TOC entry 4912 (class 0 OID 0)
-- Dependencies: 219
-- Name: product_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_product_id_seq', 20, true);


--
-- TOC entry 4728 (class 2606 OID 16615)
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4732 (class 2606 OID 16644)
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- TOC entry 4736 (class 2606 OID 16668)
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (order_item_id);


--
-- TOC entry 4734 (class 2606 OID 16656)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- TOC entry 4730 (class 2606 OID 16630)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- TOC entry 4737 (class 2606 OID 16616)
-- Name: category category_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.category(category_id);


--
-- TOC entry 4740 (class 2606 OID 16669)
-- Name: order_item order_item_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- TOC entry 4741 (class 2606 OID 16674)
-- Name: order_item order_item_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(product_id);


--
-- TOC entry 4739 (class 2606 OID 16657)
-- Name: orders orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(client_id);


--
-- TOC entry 4738 (class 2606 OID 16631)
-- Name: product product_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id);


-- Completed on 2025-09-05 19:05:00

--
-- PostgreSQL database dump complete
--

\unrestrict te3otfU8mJ0DH8qxwBBWZyfGGkihjNaRWFdkcGTB5rycgg4td1ywadxyUibFjay

