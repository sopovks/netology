CREATE TABLE products
(
    id serial NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL,
    product_name character varying(50) NOT NULL,
    lob integer NOT NULL,
    category character varying(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE agents
(
    id serial NOT NULL,
    full_name character varying(100) NOT NULL,
    sale_point_id integer NOT NULL,
    commission numeric(10, 2) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE sale_points
(
    id serial NOT NULL,
    city character varying(100) NOT NULL,
    address character varying(500) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE clients
(
    id serial NOT NULL,
    full_name character varying(100) NOT NULL,
    birth_date date NOT NULL,
    address character varying(500) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE policies
(
    id serial NOT NULL,
    sale_date date NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL,
    client_id integer NOT NULL,
    agent_id integer NOT NULL,
    sale_point_id integer NOT NULL,
    product_id integer NOT NULL,
    premium	numeric(10, 2) NOT NULL,
    commission numeric(10, 2) NOT NULL,
    insured_object text NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE policies
    ADD CONSTRAINT "Policy_Client_FK" FOREIGN KEY (client_id)
    REFERENCES clients (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT
    NOT VALID;
	
ALTER TABLE policies
    ADD CONSTRAINT "Policy_Product_FK" FOREIGN KEY (product_id)
    REFERENCES products (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

ALTER TABLE policies
    ADD CONSTRAINT "Policy_Agent_FK" FOREIGN KEY (agent_id)
    REFERENCES agents (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

ALTER TABLE policies
    ADD CONSTRAINT "Policy_SalePoint_FK" FOREIGN KEY (sale_point_id)
    REFERENCES sale_points (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;