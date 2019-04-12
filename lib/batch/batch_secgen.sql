--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.7
-- Dumped by pg_dump version 9.5.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE status AS ENUM (
    'todo',
    'running',
    'success',
    'error'
);


ALTER TYPE status OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE queue (
    id integer NOT NULL,
    secgen_args text NOT NULL,
    status status
);


ALTER TABLE queue OWNER TO postgres;

--
-- Name: queue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE queue_id_seq OWNER TO postgres;

--
-- Name: queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE queue_id_seq OWNED BY queue.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY queue ALTER COLUMN id SET DEFAULT nextval('queue_id_seq'::regclass);


--
-- Data for Name: queue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY queue (id, secgen_args, status) FROM stdin;
\.


--
-- Name: queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('queue_id_seq', 1, true);


--
-- Name: queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: queue; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE queue FROM PUBLIC;
REVOKE ALL ON TABLE queue FROM postgres;
GRANT ALL ON TABLE queue TO postgres;
GRANT ALL ON TABLE queue TO username;


--
-- Name: queue_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE queue_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE queue_id_seq FROM postgres;
GRANT ALL ON SEQUENCE queue_id_seq TO postgres;
GRANT SELECT,USAGE ON SEQUENCE queue_id_seq TO username;


--
-- PostgreSQL database dump complete
--

