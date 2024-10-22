--
-- PostgreSQL database dump
--

-- Dumped from database version 13.15
-- Dumped by pg_dump version 16.4

-- Started on 2024-10-22 14:59:21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 206 (class 1259 OID 85423)
-- Name: account_categories; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.account_categories (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    category_id bigint NOT NULL
);


ALTER TABLE public.account_categories OWNER TO sectorsj;

--
-- TOC entry 205 (class 1259 OID 85421)
-- Name: account_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.account_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.account_categories_id_seq OWNER TO sectorsj;

--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 205
-- Name: account_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.account_categories_id_seq OWNED BY public.account_categories.id;


--
-- TOC entry 201 (class 1259 OID 85391)
-- Name: accounts; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.accounts (
    id bigint NOT NULL,
    account_login character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    salt character varying(255)
);


ALTER TABLE public.accounts OWNER TO sectorsj;

--
-- TOC entry 200 (class 1259 OID 85389)
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.accounts_id_seq OWNER TO sectorsj;

--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 200
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- TOC entry 208 (class 1259 OID 85441)
-- Name: categories; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    category_name character varying(255) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.categories OWNER TO sectorsj;

--
-- TOC entry 207 (class 1259 OID 85439)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO sectorsj;

--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 207
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 217 (class 1259 OID 93171)
-- Name: emails; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.emails (
    id bigint NOT NULL,
    email_address character varying(255) NOT NULL,
    email_description character varying(255),
    password_hash character varying(255) NOT NULL,
    salt character varying(255) NOT NULL,
    account_id bigint NOT NULL,
    category_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.emails OWNER TO sectorsj;

--
-- TOC entry 216 (class 1259 OID 93169)
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.emails_id_seq OWNER TO sectorsj;

--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 216
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- TOC entry 209 (class 1259 OID 85461)
-- Name: event_publication; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.event_publication (
    id uuid NOT NULL,
    completion_date timestamp(6) with time zone,
    event_type character varying(255),
    listener_id character varying(255),
    publication_date timestamp(6) with time zone,
    serialized_event character varying(255)
);


ALTER TABLE public.event_publication OWNER TO sectorsj;

--
-- TOC entry 204 (class 1259 OID 85411)
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO sectorsj;

--
-- TOC entry 211 (class 1259 OID 85471)
-- Name: network_connections; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.network_connections (
    id bigint NOT NULL,
    connection_name character varying(255) NOT NULL,
    ipv4 character varying(15),
    ipv6 character varying(39),
    network_login character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    salt character varying(255) NOT NULL,
    account_id bigint NOT NULL,
    account_category_id bigint,
    category_id bigint NOT NULL
);


ALTER TABLE public.network_connections OWNER TO sectorsj;

--
-- TOC entry 210 (class 1259 OID 85469)
-- Name: network_connections_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.network_connections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.network_connections_id_seq OWNER TO sectorsj;

--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 210
-- Name: network_connections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.network_connections_id_seq OWNED BY public.network_connections.id;


--
-- TOC entry 218 (class 1259 OID 106575)
-- Name: newtable; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.newtable (
);


ALTER TABLE public.newtable OWNER TO sectorsj;

--
-- TOC entry 203 (class 1259 OID 85402)
-- Name: resources; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.resources (
    id bigint NOT NULL,
    resource_name character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    account_login character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.resources OWNER TO sectorsj;

--
-- TOC entry 202 (class 1259 OID 85400)
-- Name: resources_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.resources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resources_id_seq OWNER TO sectorsj;

--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 202
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.resources_id_seq OWNED BY public.resources.id;


--
-- TOC entry 213 (class 1259 OID 85492)
-- Name: users; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    phone character varying(255),
    user_description character varying(255),
    username character varying(255),
    account_id bigint NOT NULL
);


ALTER TABLE public.users OWNER TO sectorsj;

--
-- TOC entry 212 (class 1259 OID 85490)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO sectorsj;

--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 212
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 215 (class 1259 OID 85503)
-- Name: websites; Type: TABLE; Schema: public; Owner: sectorsj
--

CREATE TABLE public.websites (
    id bigint NOT NULL,
    description character varying(255),
    password_hash character varying(255) NOT NULL,
    salt character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    website_description character varying(255) NOT NULL,
    website_login character varying(255) NOT NULL,
    website_name character varying(255) NOT NULL,
    account_id bigint NOT NULL,
    account_category_id bigint,
    category_id bigint NOT NULL
);


ALTER TABLE public.websites OWNER TO sectorsj;

--
-- TOC entry 214 (class 1259 OID 85501)
-- Name: websites_id_seq; Type: SEQUENCE; Schema: public; Owner: sectorsj
--

CREATE SEQUENCE public.websites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.websites_id_seq OWNER TO sectorsj;

--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 214
-- Name: websites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sectorsj
--

ALTER SEQUENCE public.websites_id_seq OWNED BY public.websites.id;


--
-- TOC entry 2916 (class 2604 OID 85426)
-- Name: account_categories id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.account_categories ALTER COLUMN id SET DEFAULT nextval('public.account_categories_id_seq'::regclass);


--
-- TOC entry 2913 (class 2604 OID 85429)
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- TOC entry 2917 (class 2604 OID 85444)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 2921 (class 2604 OID 93174)
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- TOC entry 2918 (class 2604 OID 85474)
-- Name: network_connections id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.network_connections ALTER COLUMN id SET DEFAULT nextval('public.network_connections_id_seq'::regclass);


--
-- TOC entry 2914 (class 2604 OID 85480)
-- Name: resources id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.resources ALTER COLUMN id SET DEFAULT nextval('public.resources_id_seq'::regclass);


--
-- TOC entry 2919 (class 2604 OID 85495)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 2920 (class 2604 OID 85506)
-- Name: websites id; Type: DEFAULT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.websites ALTER COLUMN id SET DEFAULT nextval('public.websites_id_seq'::regclass);


--
-- TOC entry 2930 (class 2606 OID 85428)
-- Name: account_categories account_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.account_categories
    ADD CONSTRAINT account_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 2923 (class 2606 OID 85431)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 2932 (class 2606 OID 85449)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 2942 (class 2606 OID 93179)
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- TOC entry 2934 (class 2606 OID 85468)
-- Name: event_publication event_publication_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.event_publication
    ADD CONSTRAINT event_publication_pkey PRIMARY KEY (id);


--
-- TOC entry 2927 (class 2606 OID 85419)
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- TOC entry 2936 (class 2606 OID 85479)
-- Name: network_connections network_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.network_connections
    ADD CONSTRAINT network_connections_pkey PRIMARY KEY (id);


--
-- TOC entry 2925 (class 2606 OID 85482)
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- TOC entry 2944 (class 2606 OID 93181)
-- Name: emails uk_4jeq4kcq8fkfq1jhb5qp2mqj1; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT uk_4jeq4kcq8fkfq1jhb5qp2mqj1 UNIQUE (email_address);


--
-- TOC entry 2938 (class 2606 OID 85500)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2940 (class 2606 OID 85511)
-- Name: websites websites_pkey; Type: CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.websites
    ADD CONSTRAINT websites_pkey PRIMARY KEY (id);


--
-- TOC entry 2928 (class 1259 OID 85420)
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: sectorsj
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- TOC entry 2945 (class 2606 OID 85514)
-- Name: account_categories fk2m9299vepsq5k8u8ohjvtby9g; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.account_categories
    ADD CONSTRAINT fk2m9299vepsq5k8u8ohjvtby9g FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- TOC entry 2947 (class 2606 OID 85549)
-- Name: network_connections fk2wonxj8smxe5ddkgvgy21qmn6; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.network_connections
    ADD CONSTRAINT fk2wonxj8smxe5ddkgvgy21qmn6 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 2954 (class 2606 OID 93192)
-- Name: emails fk41wb6kvdemvj1602iltrfr1uo; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT fk41wb6kvdemvj1602iltrfr1uo FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2951 (class 2606 OID 85554)
-- Name: websites fk67r617vbx3rg2r68e0fxeky9y; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.websites
    ADD CONSTRAINT fk67r617vbx3rg2r68e0fxeky9y FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- TOC entry 2946 (class 2606 OID 85519)
-- Name: account_categories fk84o9aef3bpyqi57aakch8nlct; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.account_categories
    ADD CONSTRAINT fk84o9aef3bpyqi57aakch8nlct FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 2948 (class 2606 OID 85544)
-- Name: network_connections fk866600qg49ni5ct0xwtaoabg8; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.network_connections
    ADD CONSTRAINT fk866600qg49ni5ct0xwtaoabg8 FOREIGN KEY (account_category_id) REFERENCES public.account_categories(id);


--
-- TOC entry 2952 (class 2606 OID 85564)
-- Name: websites fk8pf79s1mdr5ha359a2fl5updd; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.websites
    ADD CONSTRAINT fk8pf79s1mdr5ha359a2fl5updd FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 2955 (class 2606 OID 93182)
-- Name: emails fkcs0wj7aej9q5ibgryd2nbo6v7; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT fkcs0wj7aej9q5ibgryd2nbo6v7 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- TOC entry 2950 (class 2606 OID 85575)
-- Name: users fkfm8rm8ks0kgj4fhlmmljkj17x; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fkfm8rm8ks0kgj4fhlmmljkj17x FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- TOC entry 2956 (class 2606 OID 93187)
-- Name: emails fkgyyal19v3egcs3doivvcim3gt; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT fkgyyal19v3egcs3doivvcim3gt FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 2953 (class 2606 OID 85559)
-- Name: websites fkpvajm38kvmqqu4mvditsdlu3h; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.websites
    ADD CONSTRAINT fkpvajm38kvmqqu4mvditsdlu3h FOREIGN KEY (account_category_id) REFERENCES public.account_categories(id);


--
-- TOC entry 2949 (class 2606 OID 85539)
-- Name: network_connections fkqbbe7g4884ywkq1xuum1n6ufx; Type: FK CONSTRAINT; Schema: public; Owner: sectorsj
--

ALTER TABLE ONLY public.network_connections
    ADD CONSTRAINT fkqbbe7g4884ywkq1xuum1n6ufx FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2024-10-22 14:59:21

--
-- PostgreSQL database dump complete
--

