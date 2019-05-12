--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE anonymous;
CREATE ROLE api;
CREATE ROLE webuser;


--
-- Role memberships
--

GRANT anonymous TO authenticator;
GRANT api TO current_user;
GRANT webuser TO authenticator;


--
-- PostgreSQL database cluster dump complete
--


--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2 (Debian 11.2-1.pgdg90+1)
-- Dumped by pg_dump version 11.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA api;



--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA auth;



--
-- Name: data; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA data;



--
-- Name: pgjwt; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA pgjwt;



--
-- Name: rabbitmq; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA rabbitmq;



--
-- Name: request; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA request;



--
-- Name: settings; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA settings;



--
-- Name: util; Type: SCHEMA; Schema: -; Owner: superuser
--

CREATE SCHEMA util;



--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--



--
-- Name: session; Type: TYPE; Schema: api; Owner: superuser
--

CREATE TYPE api.session AS (
	me json,
	token text
);



--
-- Name: user; Type: TYPE; Schema: api; Owner: superuser
--

CREATE TYPE api."user" AS (
	id integer,
	name text,
	email text,
	role text
);



--
-- Name: user_role; Type: TYPE; Schema: data; Owner: superuser
--

CREATE TYPE data.user_role AS ENUM (
    'webuser'
);



--
-- Name: login(text, text); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.login(email text, password text) RETURNS api.session
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $_$
declare
    usr record;
    usr_api record;
    result record;
begin

    EXECUTE format(
		' select row_to_json(u.*) as j'
        ' from %I."user" as u'
        ' where u.email = $1 and u.password = public.crypt($2, u.password)'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING $1, $2;

    if usr is NULL then
        raise exception 'invalid email/password';
    else
        EXECUTE format(
            ' select json_populate_record(null::%I."user", $1) as r'
		    , quote_ident(settings.get('auth.api-schema')))
   	    INTO usr_api
	    USING usr.j;

        result = (
            row_to_json(usr_api.r),
            auth.sign_jwt(auth.get_jwt_payload(usr.j))
        );
        return result;
    end if;
end
$_$;



--
-- Name: me(); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.me() RETURNS api."user"
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $_$
declare
	usr record;
begin
	
	EXECUTE format(
		' select row_to_json(u.*) as j'
		' from %I."user" as u'
		' where id = $1'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING request.user_id();

	EXECUTE format(
		'select json_populate_record(null::%I."user", $1) as r'
		, quote_ident(settings.get('auth.api-schema')))
   	INTO usr
	USING usr.j;

	return usr.r;
end
$_$;



--
-- Name: refresh_token(); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.refresh_token() RETURNS text
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $_$
declare
	usr record;
	token text;
begin

    EXECUTE format(
		' select row_to_json(u.*) as j'
        ' from %I."user" as u'
        ' where u.id = $1'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING request.user_id();

    if usr is NULL then
    	raise exception 'user not found';
    else
    	select auth.sign_jwt(auth.get_jwt_payload(usr.j))
    	into token;
    	return token;
    end if;
end
$_$;



--
-- Name: signup(text, text, text); Type: FUNCTION; Schema: api; Owner: superuser
--

CREATE FUNCTION api.signup(name text, email text, password text) RETURNS api.session
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
declare
    usr record;
    result record;
    usr_api record;
begin
    EXECUTE format(
        ' insert into %I."user" as u'
        ' (name, email, password) values'
        ' ($1, $2, $3)'
        ' returning row_to_json(u.*) as j'
		, quote_ident(settings.get('auth.data-schema')))
   	INTO usr
   	USING $1, $2, $3;

    EXECUTE format(
        ' select json_populate_record(null::%I."user", $1) as r'
        , quote_ident(settings.get('auth.api-schema')))
    INTO usr_api
    USING usr.j;

    result := (
        row_to_json(usr_api.r),
        auth.sign_jwt(auth.get_jwt_payload(usr.j))
    );

    return result;
end
$_$;



--
-- Name: encrypt_pass(); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.encrypt_pass() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if new.password is not null then
  	new.password = public.crypt(new.password, public.gen_salt('bf'));
  end if;
  return new;
end
$$;



--
-- Name: get_jwt_payload(json); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.get_jwt_payload(json) RETURNS json
    LANGUAGE sql STABLE
    AS $_$
    select json_build_object(
                'role', $1->'role',
                'user_id', $1->'id',
                'exp', extract(epoch from now())::integer + settings.get('jwt_lifetime')::int -- token expires in 1 hour
            )
$_$;



--
-- Name: set_auth_endpoints_privileges(text, text, text[]); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.set_auth_endpoints_privileges(schema text, anonymous text, roles text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare r record;
begin
  execute 'grant execute on function ' || quote_ident(schema) || '.login(text,text) to ' || quote_ident(anonymous);
  execute 'grant execute on function ' || quote_ident(schema) || '.signup(text,text,text) to ' || quote_ident(anonymous);
  for r in
     select unnest(roles) as role
  loop
     execute 'grant execute on function ' || quote_ident(schema) || '.me() to ' || quote_ident(r.role);
     execute 'grant execute on function ' || quote_ident(schema) || '.login(text,text) to ' || quote_ident(r.role);
     execute 'grant execute on function ' || quote_ident(schema) || '.refresh_token() to ' || quote_ident(r.role);
  end loop;
end;
$$;



--
-- Name: sign_jwt(json); Type: FUNCTION; Schema: auth; Owner: superuser
--

CREATE FUNCTION auth.sign_jwt(json) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
    select pgjwt.sign($1, settings.get('jwt_secret'))
$_$;



--
-- Name: set_updated_on(); Type: FUNCTION; Schema: data; Owner: superuser
--

CREATE FUNCTION data.set_updated_on() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_on = now();
  return new;
end
$$;



--
-- Name: algorithm_sign(text, text, text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.algorithm_sign(signables text, secret text, algorithm text) RETURNS text
    LANGUAGE sql
    AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END)  -- hmac throws error
SELECT pgjwt.url_encode(public.hmac(signables, secret, (select * FROM alg)));
$$;



--
-- Name: sign(json, text, text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.sign(payload json, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS text
    LANGUAGE sql
    AS $$
WITH
  header AS (
    SELECT pgjwt.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8'))
    ),
  payload AS (
    SELECT pgjwt.url_encode(convert_to(payload::text, 'utf8'))
    ),
  signables AS (
    SELECT (SELECT * FROM header) || '.' || (SELECT * FROM payload)
    )
SELECT
    (SELECT * FROM signables)
    || '.' ||
    pgjwt.algorithm_sign((SELECT * FROM signables), secret, algorithm);
$$;



--
-- Name: url_decode(text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.url_decode(data text) RETURNS bytea
    LANGUAGE sql
    AS $$
WITH t AS (SELECT translate(data, '-_', '+/')),
     rem AS (SELECT length((SELECT * FROM t)) % 4) -- compute padding size
    SELECT decode(
        (SELECT * FROM t) ||
        CASE WHEN (SELECT * FROM rem) > 0
           THEN repeat('=', (4 - (SELECT * FROM rem)))
           ELSE '' END,
    'base64');
$$;



--
-- Name: url_encode(bytea); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.url_encode(data bytea) RETURNS text
    LANGUAGE sql
    AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;



--
-- Name: verify(text, text, text); Type: FUNCTION; Schema: pgjwt; Owner: superuser
--

CREATE FUNCTION pgjwt.verify(token text, secret text, algorithm text DEFAULT 'HS256'::text) RETURNS TABLE(header json, payload json, valid boolean)
    LANGUAGE sql
    AS $$
  SELECT
    convert_from(pgjwt.url_decode(r[1]), 'utf8')::json AS header,
    convert_from(pgjwt.url_decode(r[2]), 'utf8')::json AS payload,
    r[3] = pgjwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
  FROM regexp_split_to_array(token, '\.') r;
$$;



--
-- Name: on_row_change(); Type: FUNCTION; Schema: rabbitmq; Owner: superuser
--

CREATE FUNCTION rabbitmq.on_row_change() RETURNS trigger
    LANGUAGE plpgsql STABLE
    AS $$
  declare
    routing_key text;
    row jsonb;
    config jsonb;
    excluded_columns text[];
    col text;
  begin
    routing_key := 'row_change'
                   '.table-'::text || TG_TABLE_NAME::text || 
                   '.event-'::text || TG_OP::text;
    if (TG_OP = 'DELETE') then
        row := row_to_json(old)::jsonb;
    elsif (TG_OP = 'UPDATE') then
        row := row_to_json(new)::jsonb;
    elsif (TG_OP = 'INSERT') then
        row := row_to_json(new)::jsonb;
    end if;

    -- decide what row columns to send based on the config parameter
    -- there is a 8000 byte hard limit on the payload size so sending many big columns is not possible
    if ( TG_NARGS = 1 ) then
      config := TG_ARGV[0];
      if (config ? 'include') then
          --excluded_columns := ARRAY(SELECT unnest(jsonb_object_keys(row)::text[]) EXCEPT SELECT unnest( array(select jsonb_array_elements_text(config->'include')) ));
          -- this is a diff between two arrays
          excluded_columns := array(
            -- array of all row columns
            select unnest(
              array(select jsonb_object_keys(row))
            ) 
            except
            -- array of included columns
            select unnest(
              array(select jsonb_array_elements_text(config->'include'))
            )
          );
      end if;

      if (config ? 'exclude') then
        excluded_columns := array(select jsonb_array_elements_text(config->'exclude'));
      end if;

      if (current_setting('server_version_num')::int >= 100000) then
          row := row - excluded_columns;
      else
          FOREACH col IN ARRAY excluded_columns
          LOOP
            row := row - col;
          END LOOP;
      end if;
    end if;
    
    perform rabbitmq.send_message('events', routing_key, row::text);
    return null;
  end;
$$;



--
-- Name: send_message(text, text, text); Type: FUNCTION; Schema: rabbitmq; Owner: superuser
--

CREATE FUNCTION rabbitmq.send_message(channel text, routing_key text, message text) RETURNS void
    LANGUAGE sql STABLE
    AS $$
     
  select  pg_notify(
    channel,  
    routing_key || '|' || message
  );
$$;



--
-- Name: cookie(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.cookie(c text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.env_var('request.cookie.' || c);
$$;



--
-- Name: env_var(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.env_var(v text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select current_setting(v, true);
$$;



--
-- Name: header(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.header(h text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.env_var('request.header.' || h);
$$;



--
-- Name: jwt_claim(text); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.jwt_claim(c text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.env_var('request.jwt.claim.' || c);
$$;



--
-- Name: user_id(); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.user_id() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
    select 
    case request.jwt_claim('user_id') 
    when '' then 0
    else request.jwt_claim('user_id')::int
	end
$$;



--
-- Name: user_role(); Type: FUNCTION; Schema: request; Owner: superuser
--

CREATE FUNCTION request.user_role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select request.jwt_claim('role')::text;
$$;



--
-- Name: get(text); Type: FUNCTION; Schema: settings; Owner: superuser
--

CREATE FUNCTION settings.get(text) RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
    select value from settings.secrets where key = $1
$_$;



--
-- Name: set(text, text); Type: FUNCTION; Schema: settings; Owner: superuser
--

CREATE FUNCTION settings.set(text, text) RETURNS void
    LANGUAGE sql SECURITY DEFINER
    AS $_$
	insert into settings.secrets (key, value)
	values ($1, $2)
	on conflict (key) do update
	set value = $2;
$_$;



--
-- Name: mutation_comments_trigger(); Type: FUNCTION; Schema: util; Owner: superuser
--

CREATE FUNCTION util.mutation_comments_trigger() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
    c record;
    parent_type text;
begin
    if (tg_op = 'DELETE') then
        if old.parent_type = 'task' then
            delete from data.task_comment where id = old.id;
            if not found then return null; end if;
        elsif old.parent_type = 'project' then
            delete from data.project_comment where id = old.id;
            if not found then return null; end if;
        end if;
        return old;
    elsif (tg_op = 'UPDATE') then
        if (new.parent_type = 'task' or old.parent_type = 'task') then
            update data.task_comment 
            set 
                body = coalesce(new.body, old.body),
                task_id = coalesce(new.task_id, old.task_id)
            where id = old.id
            returning * into c;
            if not found then return null; end if;
            return (c.id, c.body, 'task'::text, c.task_id, null::int, c.task_id, c.created_on, c.updated_on);
        elsif (new.parent_type = 'project' or old.parent_type = 'project') then
            update data.project_comment 
            set 
                body = coalesce(new.body, old.body),
                project_id = coalesce(new.project_id, old.project_id)
            where id = old.id
            returning * into c;
            if not found then return null; end if;
            return (c.id, c.body, 'project'::text, c.project_id, c.project_id, null::int, c.created_on, c.updated_on);
        end if;
    elsif (tg_op = 'INSERT') then
        if new.parent_type = 'task' then
            insert into data.task_comment (body, task_id)
            values(new.body, new.task_id)
            returning * into c;
            return (c.id, c.body, 'task'::text, c.task_id, null::int, c.task_id, c.created_on, c.updated_on);
        elsif new.parent_type = 'project' then
            insert into data.project_comment (body, project_id)
            values(new.body, new.project_id)
            returning * into c;
            return (c.id, c.body, 'project'::text, c.project_id, c.project_id, null::int, c.created_on, c.updated_on);
        end if;

    end if;
    return null;
end;
$$;



SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: client; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.client (
    id integer NOT NULL,
    name text NOT NULL,
    address text,
    user_id integer DEFAULT request.user_id() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone,
    CONSTRAINT client_check CHECK (((updated_on IS NULL) OR (updated_on > created_on))),
    CONSTRAINT client_name_check CHECK (((length(name) > 2) AND (length(name) < 100)))
);



--
-- Name: clients; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.clients AS
 SELECT client.id,
    client.name,
    client.address,
    client.created_on,
    client.updated_on
   FROM data.client;


ALTER TABLE api.clients OWNER TO api;

--
-- Name: project_comment; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.project_comment (
    id integer NOT NULL,
    body text NOT NULL,
    project_id integer NOT NULL,
    user_id integer DEFAULT request.user_id() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone,
    CONSTRAINT project_comment_body_check CHECK ((length(body) > 2)),
    CONSTRAINT project_comment_check CHECK (((updated_on IS NULL) OR (updated_on > created_on)))
);



--
-- Name: task_comment; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.task_comment (
    id integer NOT NULL,
    body text NOT NULL,
    task_id integer NOT NULL,
    user_id integer DEFAULT request.user_id() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone,
    CONSTRAINT task_comment_body_check CHECK ((length(body) > 2)),
    CONSTRAINT task_comment_check CHECK (((updated_on IS NULL) OR (updated_on > created_on)))
);



--
-- Name: comments; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.comments AS
 SELECT project_comment.id,
    project_comment.body,
    'project'::text AS parent_type,
    project_comment.project_id AS parent_id,
    project_comment.project_id,
    NULL::integer AS task_id,
    project_comment.created_on,
    project_comment.updated_on
   FROM data.project_comment
UNION
 SELECT task_comment.id,
    task_comment.body,
    'task'::text AS parent_type,
    task_comment.task_id AS parent_id,
    NULL::integer AS project_id,
    task_comment.task_id,
    task_comment.created_on,
    task_comment.updated_on
   FROM data.task_comment;


ALTER TABLE api.comments OWNER TO api;

--
-- Name: project; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.project (
    id integer NOT NULL,
    name text NOT NULL,
    client_id integer NOT NULL,
    user_id integer DEFAULT request.user_id() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone,
    CONSTRAINT project_check CHECK (((updated_on IS NULL) OR (updated_on > created_on))),
    CONSTRAINT project_name_check CHECK ((length(name) > 2))
);



--
-- Name: projects; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.projects AS
 SELECT project.id,
    project.name,
    project.client_id,
    project.created_on,
    project.updated_on
   FROM data.project;


ALTER TABLE api.projects OWNER TO api;

--
-- Name: task; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.task (
    id integer NOT NULL,
    name text NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    project_id integer NOT NULL,
    user_id integer DEFAULT request.user_id() NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone,
    CONSTRAINT task_check CHECK (((updated_on IS NULL) OR (updated_on > created_on))),
    CONSTRAINT task_name_check CHECK ((length(name) > 2))
);



--
-- Name: tasks; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.tasks AS
 SELECT task.id,
    task.name,
    task.completed,
    task.project_id,
    task.created_on,
    task.updated_on
   FROM data.task;


ALTER TABLE api.tasks OWNER TO api;

--
-- Name: todo; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data.todo (
    id integer NOT NULL,
    todo text NOT NULL,
    private boolean DEFAULT true,
    owner_id integer DEFAULT request.user_id()
);



--
-- Name: todos; Type: VIEW; Schema: api; Owner: api
--

CREATE VIEW api.todos AS
 SELECT todo.id,
    todo.todo,
    todo.private,
    (todo.owner_id = request.user_id()) AS mine
   FROM data.todo;


ALTER TABLE api.todos OWNER TO api;

--
-- Name: client_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: client_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.client_id_seq OWNED BY data.client.id;


--
-- Name: project_comment_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.project_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: project_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.project_comment_id_seq OWNED BY data.project_comment.id;


--
-- Name: project_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: project_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.project_id_seq OWNED BY data.project.id;


--
-- Name: task_comment_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.task_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: task_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.task_comment_id_seq OWNED BY data.task_comment.id;


--
-- Name: task_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: task_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.task_id_seq OWNED BY data.task.id;


--
-- Name: todo_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.todo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: todo_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.todo_id_seq OWNED BY data.todo.id;


--
-- Name: user; Type: TABLE; Schema: data; Owner: superuser
--

CREATE TABLE data."user" (
    id integer NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    role data.user_role DEFAULT (settings.get('auth.default-role'::text))::data.user_role NOT NULL,
    CONSTRAINT user_email_check CHECK ((email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)),
    CONSTRAINT user_name_check CHECK ((length(name) > 2))
);



--
-- Name: user_id_seq; Type: SEQUENCE; Schema: data; Owner: superuser
--

CREATE SEQUENCE data.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: data; Owner: superuser
--

ALTER SEQUENCE data.user_id_seq OWNED BY data."user".id;


--
-- Name: secrets; Type: TABLE; Schema: settings; Owner: superuser
--

CREATE TABLE settings.secrets (
    key text NOT NULL,
    value text NOT NULL
);



--
-- Name: client id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.client ALTER COLUMN id SET DEFAULT nextval('data.client_id_seq'::regclass);


--
-- Name: project id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project ALTER COLUMN id SET DEFAULT nextval('data.project_id_seq'::regclass);


--
-- Name: project_comment id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project_comment ALTER COLUMN id SET DEFAULT nextval('data.project_comment_id_seq'::regclass);


--
-- Name: task id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task ALTER COLUMN id SET DEFAULT nextval('data.task_id_seq'::regclass);


--
-- Name: task_comment id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task_comment ALTER COLUMN id SET DEFAULT nextval('data.task_comment_id_seq'::regclass);


--
-- Name: todo id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.todo ALTER COLUMN id SET DEFAULT nextval('data.todo_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data."user" ALTER COLUMN id SET DEFAULT nextval('data.user_id_seq'::regclass);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id);


--
-- Name: project_comment project_comment_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project_comment
    ADD CONSTRAINT project_comment_pkey PRIMARY KEY (id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: todo todo_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.todo
    ADD CONSTRAINT todo_pkey PRIMARY KEY (id);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: secrets secrets_pkey; Type: CONSTRAINT; Schema: settings; Owner: superuser
--

ALTER TABLE ONLY settings.secrets
    ADD CONSTRAINT secrets_pkey PRIMARY KEY (key);


--
-- Name: client_user_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX client_user_id_index ON data.client USING btree (user_id);


--
-- Name: project_client_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX project_client_id_index ON data.project USING btree (client_id);


--
-- Name: project_comment_project_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX project_comment_project_id_index ON data.project_comment USING btree (project_id);


--
-- Name: project_comment_user_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX project_comment_user_id_index ON data.project_comment USING btree (user_id);


--
-- Name: project_user_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX project_user_id_index ON data.project USING btree (user_id);


--
-- Name: task_comment_task_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX task_comment_task_id_index ON data.task_comment USING btree (task_id);


--
-- Name: task_comment_user_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX task_comment_user_id_index ON data.task_comment USING btree (user_id);


--
-- Name: task_project_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX task_project_id_index ON data.task USING btree (project_id);


--
-- Name: task_user_id_index; Type: INDEX; Schema: data; Owner: superuser
--

CREATE INDEX task_user_id_index ON data.task USING btree (user_id);


--
-- Name: comments comments_mutation; Type: TRIGGER; Schema: api; Owner: api
--

CREATE TRIGGER comments_mutation INSTEAD OF INSERT OR DELETE OR UPDATE ON api.comments FOR EACH ROW EXECUTE PROCEDURE util.mutation_comments_trigger();


--
-- Name: client client_set_updated_on; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER client_set_updated_on BEFORE UPDATE ON data.client FOR EACH ROW EXECUTE PROCEDURE data.set_updated_on();


--
-- Name: project_comment project_comment_set_updated_on; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER project_comment_set_updated_on BEFORE UPDATE ON data.project_comment FOR EACH ROW EXECUTE PROCEDURE data.set_updated_on();


--
-- Name: project project_set_updated_on; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER project_set_updated_on BEFORE UPDATE ON data.project FOR EACH ROW EXECUTE PROCEDURE data.set_updated_on();


--
-- Name: todo send_change_event; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER send_change_event AFTER INSERT OR DELETE OR UPDATE ON data.todo FOR EACH ROW EXECUTE PROCEDURE rabbitmq.on_row_change('{"include":["id","todo"]}');


--
-- Name: user send_change_event; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER send_change_event AFTER INSERT OR DELETE OR UPDATE ON data."user" FOR EACH ROW EXECUTE PROCEDURE rabbitmq.on_row_change();


--
-- Name: task_comment task_comment_set_updated_on; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER task_comment_set_updated_on BEFORE UPDATE ON data.task_comment FOR EACH ROW EXECUTE PROCEDURE data.set_updated_on();


--
-- Name: task task_set_updated_on; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER task_set_updated_on BEFORE UPDATE ON data.task FOR EACH ROW EXECUTE PROCEDURE data.set_updated_on();


--
-- Name: user user_encrypt_pass_trigger; Type: TRIGGER; Schema: data; Owner: superuser
--

CREATE TRIGGER user_encrypt_pass_trigger BEFORE INSERT OR UPDATE ON data."user" FOR EACH ROW EXECUTE PROCEDURE auth.encrypt_pass();


--
-- Name: client client_user_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.client
    ADD CONSTRAINT client_user_id_fkey FOREIGN KEY (user_id) REFERENCES data."user"(id);


--
-- Name: project project_client_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project
    ADD CONSTRAINT project_client_id_fkey FOREIGN KEY (client_id) REFERENCES data.client(id);


--
-- Name: project_comment project_comment_project_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project_comment
    ADD CONSTRAINT project_comment_project_id_fkey FOREIGN KEY (project_id) REFERENCES data.project(id);


--
-- Name: project_comment project_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project_comment
    ADD CONSTRAINT project_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES data."user"(id);


--
-- Name: project project_user_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.project
    ADD CONSTRAINT project_user_id_fkey FOREIGN KEY (user_id) REFERENCES data."user"(id);


--
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES data.task(id);


--
-- Name: task_comment task_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task_comment
    ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES data."user"(id);


--
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES data.project(id);


--
-- Name: task task_user_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.task
    ADD CONSTRAINT task_user_id_fkey FOREIGN KEY (user_id) REFERENCES data."user"(id);


--
-- Name: todo todo_owner_id_fkey; Type: FK CONSTRAINT; Schema: data; Owner: superuser
--

ALTER TABLE ONLY data.todo
    ADD CONSTRAINT todo_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES data."user"(id);


--
-- Name: client access_own_rows; Type: POLICY; Schema: data; Owner: superuser
--

CREATE POLICY access_own_rows ON data.client TO api USING (((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id)));


--
-- Name: project access_own_rows; Type: POLICY; Schema: data; Owner: superuser
--

CREATE POLICY access_own_rows ON data.project TO api USING (((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id)));


--
-- Name: task access_own_rows; Type: POLICY; Schema: data; Owner: superuser
--

CREATE POLICY access_own_rows ON data.task TO api USING (((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id)));


--
-- Name: project_comment access_own_rows; Type: POLICY; Schema: data; Owner: superuser
--

CREATE POLICY access_own_rows ON data.project_comment TO api USING (((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id)));


--
-- Name: task_comment access_own_rows; Type: POLICY; Schema: data; Owner: superuser
--

CREATE POLICY access_own_rows ON data.task_comment TO api USING (((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id)));


--
-- Name: client; Type: ROW SECURITY; Schema: data; Owner: superuser
--

ALTER TABLE data.client ENABLE ROW LEVEL SECURITY;

--
-- Name: project; Type: ROW SECURITY; Schema: data; Owner: superuser
--

ALTER TABLE data.project ENABLE ROW LEVEL SECURITY;

--
-- Name: project_comment; Type: ROW SECURITY; Schema: data; Owner: superuser
--

ALTER TABLE data.project_comment ENABLE ROW LEVEL SECURITY;

--
-- Name: task; Type: ROW SECURITY; Schema: data; Owner: superuser
--

ALTER TABLE data.task ENABLE ROW LEVEL SECURITY;

--
-- Name: task_comment; Type: ROW SECURITY; Schema: data; Owner: superuser
--

ALTER TABLE data.task_comment ENABLE ROW LEVEL SECURITY;

--
-- Name: todo; Type: ROW SECURITY; Schema: data; Owner: superuser
--

ALTER TABLE data.todo ENABLE ROW LEVEL SECURITY;

--
-- Name: todo todo_access_policy; Type: POLICY; Schema: data; Owner: superuser
--

CREATE POLICY todo_access_policy ON data.todo TO api USING ((((request.user_role() = 'webuser'::text) AND (request.user_id() = owner_id)) OR (private = false))) WITH CHECK (((request.user_role() = 'webuser'::text) AND (request.user_id() = owner_id)));


--
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: superuser
--

GRANT USAGE ON SCHEMA api TO anonymous;
GRANT USAGE ON SCHEMA api TO webuser;


--
-- Name: SCHEMA rabbitmq; Type: ACL; Schema: -; Owner: superuser
--

GRANT USAGE ON SCHEMA rabbitmq TO PUBLIC;


--
-- Name: SCHEMA request; Type: ACL; Schema: -; Owner: superuser
--

GRANT USAGE ON SCHEMA request TO PUBLIC;


--
-- Name: FUNCTION login(email text, password text); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.login(email text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION api.login(email text, password text) TO anonymous;
GRANT ALL ON FUNCTION api.login(email text, password text) TO webuser;


--
-- Name: FUNCTION me(); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.me() FROM PUBLIC;
GRANT ALL ON FUNCTION api.me() TO webuser;


--
-- Name: FUNCTION refresh_token(); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.refresh_token() FROM PUBLIC;
GRANT ALL ON FUNCTION api.refresh_token() TO webuser;


--
-- Name: FUNCTION signup(name text, email text, password text); Type: ACL; Schema: api; Owner: superuser
--

REVOKE ALL ON FUNCTION api.signup(name text, email text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION api.signup(name text, email text, password text) TO anonymous;


--
-- Name: TABLE client; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE data.client TO api;


--
-- Name: TABLE clients; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.clients TO webuser;


--
-- Name: TABLE project_comment; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE data.project_comment TO api;


--
-- Name: TABLE task_comment; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE data.task_comment TO api;


--
-- Name: TABLE comments; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.comments TO webuser;


--
-- Name: TABLE project; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE data.project TO api;


--
-- Name: TABLE projects; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.projects TO webuser;


--
-- Name: TABLE task; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE data.task TO api;


--
-- Name: TABLE tasks; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.tasks TO webuser;


--
-- Name: TABLE todo; Type: ACL; Schema: data; Owner: superuser
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE data.todo TO api;


--
-- Name: TABLE todos; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.todos TO webuser;


--
-- Name: COLUMN todos.id; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT(id) ON TABLE api.todos TO anonymous;


--
-- Name: COLUMN todos.todo; Type: ACL; Schema: api; Owner: api
--

GRANT SELECT(todo) ON TABLE api.todos TO anonymous;


--
-- Name: SEQUENCE client_id_seq; Type: ACL; Schema: data; Owner: superuser
--

GRANT USAGE ON SEQUENCE data.client_id_seq TO webuser;


--
-- Name: SEQUENCE project_comment_id_seq; Type: ACL; Schema: data; Owner: superuser
--

GRANT USAGE ON SEQUENCE data.project_comment_id_seq TO webuser;


--
-- Name: SEQUENCE project_id_seq; Type: ACL; Schema: data; Owner: superuser
--

GRANT USAGE ON SEQUENCE data.project_id_seq TO webuser;


--
-- Name: SEQUENCE task_comment_id_seq; Type: ACL; Schema: data; Owner: superuser
--

GRANT USAGE ON SEQUENCE data.task_comment_id_seq TO webuser;


--
-- Name: SEQUENCE task_id_seq; Type: ACL; Schema: data; Owner: superuser
--

GRANT USAGE ON SEQUENCE data.task_id_seq TO webuser;


--
-- Name: SEQUENCE todo_id_seq; Type: ACL; Schema: data; Owner: superuser
--

GRANT USAGE ON SEQUENCE data.todo_id_seq TO webuser;


--
-- PostgreSQL database dump complete
--

