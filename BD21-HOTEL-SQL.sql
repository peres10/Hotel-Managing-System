DROP SEQUENCE cliente_seq;
CREATE SEQUENCE cliente_seq;

DROP SEQUENCE quartos_seq;
CREATE SEQUENCE quartos_seq;

DROP SEQUENCE funcionarios_seq;
CREATE SEQUENCE funcionarios_seq;

DROP SEQUENCE reservas_seq;
CREATE SEQUENCE reservas_seq;

DROP SEQUENCE pagamentos_seq;
CREATE SEQUENCE pagamentos_seq;

DROP SEQUENCE tipo_quarto_seq;
CREATE SEQUENCE tipo_quarto_seq;

DROP TABLE pessoas CASCADE CONSTRAINTS;
CREATE TABLE pessoas (
    num_cc NUMBER NOT NULL,
    contacto VARCHAR(12) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    PRIMARY KEY(num_cc)
);

DROP TABLE clientes CASCADE CONSTRAINTS;
CREATE TABLE clientes (
    num_cc NUMBER NOT NULL,
    id_cliente NUMBER NOT NULL,
    UNIQUE(id_cliente),
    PRIMARY KEY(num_cc),
    FOREIGN KEY(num_cc) REFERENCES pessoas ON DELETE CASCADE
);

DROP TABLE funcionarios CASCADE CONSTRAINTS;
CREATE TABLE funcionarios (
    num_cc NUMBER NOT NULL,
    id_funcionario NUMBER NOT NULL,
    dias_trabalho_p_sem NUMBER NOT NULL CHECK(dias_trabalho_p_sem>=0),
    salario_p_hora REAL NOT NULL CHECK(salario_p_hora>=0),
    horas_inicio NUMBER NOT NULL CHECK (horas_inicio >= 0) CHECK (horas_inicio <= 23), 
    horas_fim NUMBER NOT NULL CHECK (horas_fim >= 0) CHECK (horas_fim <= 23),
    CONSTRAINT chk_hours CHECK(horas_inicio < horas_fim),
    UNIQUE(id_funcionario),
    PRIMARY KEY(num_cc),
    FOREIGN KEY(num_cc) REFERENCES pessoas ON DELETE CASCADE
);

DROP TABLE funcionarios_de_limpeza CASCADE CONSTRAINTS;
CREATE TABLE funcionarios_de_limpeza (
    id_funcionario NUMBER NOT NULL,
    PRIMARY KEY(id_funcionario),
    FOREIGN KEY(id_funcionario) REFERENCES funcionarios(id_funcionario) ON DELETE CASCADE
);

DROP TABLE funcionarios_de_balcao CASCADE CONSTRAINTS;
CREATE TABLE funcionarios_de_balcao (
    id_funcionario NUMBER NOT NULL,
    PRIMARY KEY(id_funcionario),
    FOREIGN KEY(id_funcionario) REFERENCES funcionarios(id_funcionario) ON DELETE CASCADE
);

DROP TABLE outros_funcionarios CASCADE CONSTRAINTS;
CREATE TABLE outros_funcionarios (
    id_funcionario NUMBER NOT NULL,
    desc_funcao VARCHAR(50),
    PRIMARY KEY(id_funcionario),
    FOREIGN KEY(id_funcionario) REFERENCES funcionarios(id_funcionario) ON DELETE CASCADE
);

DROP TABLE reservas CASCADE CONSTRAINTS;
CREATE TABLE reservas (
    id_reserva NUMBER NOT NULL,
    id_cliente NUMBER NOT NULL,
    data_reserva DATE NOT NULL,
    num_hospedes NUMBER NOT NULL,
    check_in TIMESTAMP ,
    check_out TIMESTAMP ,
    PRIMARY KEY(id_reserva),
    FOREIGN KEY(id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE
);

DROP TABLE pagamentos CASCADE CONSTRAINTS;
CREATE TABLE pagamentos (
    id_reserva NUMBER NOT NULL,
    num_pagamento NUMBER NOT NULL,
    tipo_pagamento VARCHAR(25) NOT NULL,
    valor REAL NOT NULL,
    data TIMESTAMP NOT NULL,
    UNIQUE(num_pagamento),
    PRIMARY KEY(id_reserva),
    FOREIGN KEY(id_reserva) REFERENCES reservas ON DELETE CASCADE
);

DROP TABLE reservas_online CASCADE CONSTRAINTS;
CREATE TABLE reservas_online (
  id_reserva NUMBER NOT NULL,
  email VARCHAR(50) NOT NULL CHECK (
    REGEXP_LIKE ( email,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
  ),    
  PRIMARY KEY(id_reserva),
  FOREIGN KEY(id_reserva) REFERENCES reservas ON DELETE CASCADE
);

DROP TABLE reservas_balcao CASCADE CONSTRAINTS;
CREATE TABLE reservas_balcao (
    id_reserva NUMBER NOT NULL,
    id_funcionario NUMBER NOT NULL,
    PRIMARY KEY(id_reserva),
    FOREIGN KEY(id_reserva) REFERENCES reservas ON DELETE CASCADE,
    FOREIGN KEY(id_funcionario) REFERENCES funcionarios_de_balcao ON DELETE CASCADE
);

DROP TABLE tipos_de_quarto CASCADE CONSTRAINTS;
CREATE TABLE tipos_de_quarto(
    id_tipo_quarto NUMBER NOT NULL,
    num_camas NUMBER NOT NULL,
    descricao_tipo_quarto VARCHAR(100) NOT NULL,
    PRIMARY KEY(id_tipo_quarto)
);

DROP TABLE quartos CASCADE CONSTRAINTS;
CREATE TABLE quartos (
    id_quarto NUMBER NOT NULL,
    id_tipo_quarto NUMBER NOT NULL,
    andar NUMBER NOT NULL,
    numero_quarto NUMBER NOT NULL,
    descricao VARCHAR(100),
    PRIMARY KEY(id_quarto),
    FOREIGN KEY(id_tipo_quarto) REFERENCES tipos_de_quarto ON DELETE CASCADE
);

DROP TABLE precos_quarto CASCADE CONSTRAINTS;
CREATE TABLE precos_quarto(
    id_quarto NUMBER NOT NULL,
    dia_inicio_valor DATE NOT NULL,
    preco REAL NOT NULL,
    preco_esta_ativo CHAR(1) NOT NULL, --Y if yes N if no
    PRIMARY KEY(dia_inicio_valor,id_quarto),
    FOREIGN KEY(id_quarto) REFERENCES quartos ON DELETE CASCADE
);

DROP TABLE estados_quartos CASCADE CONSTRAINTS;
CREATE TABLE estados_quartos(
    id_quarto NUMBER NOT NULL,
    descricao_estado VARCHAR(100) NOT NULL,
    pronto_para_utilizar CHAR(1) NOT NULL, --Y if yes N if no
    PRIMARY KEY(id_quarto),
    FOREIGN KEY(id_quarto) REFERENCES quartos ON DELETE CASCADE
);

DROP TABLE limpezas_quartos CASCADE CONSTRAINTS;
CREATE TABLE limpezas_quartos(
    id_quarto NUMBER NOT NULL,
    id_funcionario NUMBER NOT NULL,
    dia DATE NOT NULL,
    horas_inicio NUMBER NOT NULL CHECK (horas_inicio >= 0) CHECK (horas_inicio <= 23), 
    horas_fim NUMBER NOT NULL CHECK (horas_fim >= 0) CHECK (horas_fim <= 23),
    CONSTRAINT chk_hours_limpeza CHECK(horas_inicio < horas_fim),
    PRIMARY KEY (id_quarto,id_funcionario,dia),
    FOREIGN KEY(id_quarto) REFERENCES quartos ON DELETE CASCADE,
    FOREIGN KEY(id_funcionario) REFERENCES funcionarios_de_limpeza ON DELETE CASCADE
);

DROP TABLE quartos_reservados CASCADE CONSTRAINTS;
CREATE TABLE quartos_reservados(
    id_reserva NUMBER NOT NULL,
    id_quarto NUMBER NOT NULL,
    num_quarto_reserva NUMBER NOT NULL,
    PRIMARY KEY(id_reserva,id_quarto),
    FOREIGN KEY(id_quarto) REFERENCES quartos ON DELETE CASCADE,
    FOREIGN KEY(id_reserva) REFERENCES reservas ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER cliente_bir
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
	SELECT cliente_seq.NEXTVAL
	INTO :new.id_cliente
	FROM dual;
END;
/
CREATE OR REPLACE TRIGGER funcionarios_bir
BEFORE INSERT ON funcionarios
FOR EACH ROW
BEGIN
	SELECT funcionarios_seq.NEXTVAL
	INTO :new.id_funcionario
	FROM dual;
END;
/
CREATE OR REPLACE TRIGGER reservas_bir
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
	SELECT reservas_seq.NEXTVAL
	INTO :new.id_reserva
	FROM dual;
END;
/
CREATE OR REPLACE TRIGGER pagamentos_bir
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
	SELECT pagamentos_seq.NEXTVAL
	INTO :new.num_pagamento
	FROM dual;
END;
/
CREATE OR REPLACE TRIGGER tipo_quarto_bir
BEFORE INSERT ON tipos_de_quarto
FOR EACH ROW
BEGIN
	SELECT tipo_quarto_seq.NEXTVAL
	INTO :new.id_tipo_quarto
	FROM dual;
END;
/
CREATE OR REPLACE TRIGGER quartos_bir
BEFORE INSERT ON quartos
FOR EACH ROW
BEGIN
	SELECT quartos_seq.NEXTVAL
	INTO :new.id_quarto
	FROM dual;
END;
/

--pessoas
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('13424328','351907322456','Manuela da Cunha');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('25435433','351906673018','Valetina da Mota');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('34304135','351914856690','Guilherme da Conceição');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('41341414','351981622364','Igor dias');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('45356452','351900240908','Esther da Mota');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('65435432','351919001596','Ana Luiza Araújo');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('71431422','351966224387','Maria Fernanda Costela');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('04935452','351994847988','Anthony Castro');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('43248321','351995559599','Nina da Rocha');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('95334543','351921547896','Gustavo Nunes');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('43534543','351976543246','Benjamin Gonçalves');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('53534131','351912343463','Heloísa Nogueira');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('94324242','351901232424','Alice da Paz');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('45464541','351924656743','Stella Carvalho');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('57655465','351976676542','Maria Eduarda Cardoso');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('65742432','351920343254','Vicente Novaes');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('45496542','351975643242','Ian Cardoso');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('56463542','351989595334','Lucas Gabriel Rodrigues');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('96785674','351909454242','Pedro Carvalho');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('46353453','351910321423','Mariane Ferreira');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('69545435','351945390623','Rebeca Pinto');
INSERT INTO pessoas(num_cc,contacto,nome) VALUES ('75765632','351943433523','Gustavo Henrique Almeida');
---------------------------------------------------------------
--clientes
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Manuela da Cunha';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Guilherme da Conceição';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Esther da Mota';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Valetina da Mota';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Igor dias';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Maria Fernanda Costela';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Anthony Castro';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Nina da Rocha';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Gustavo Nunes';
INSERT INTO clientes (num_cc)
    SELECT num_cc FROM pessoas
    WHERE nome = 'Benjamin Gonçalves';
-----------------------------------------------------------------
-- funcionarios
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (53534131,5,15,7,16); 
--limpeza
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (94324242,5,17,8,18); 
--limpeza
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (69545435,4,13,8,14); 
--limpeza
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (45464541,4,20,7,20); 
--balcao
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (57655465,5,20,17,23); 
--balcao
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (65742432,3,15,10,18); 
--balcao
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (45496542,7,20,9,20); 
--diretor
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (56463542,7,20,14,16); 
--canalizador
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (96785674,7,20,15,19); 
--eletricista
INSERT INTO funcionarios(num_cc, dias_trabalho_p_sem, salario_p_hora, horas_inicio, horas_fim) 
    VALUES (46353453,7,13,11,21); 
--cozinheiro
-----------------------------------------------------------------
--fncionarios limpeza
INSERT INTO funcionarios_de_limpeza(id_funcionario) 
    SELECT id_funcionario FROM funcionarios
    WHERE num_cc = 53534131;
INSERT INTO funcionarios_de_limpeza(id_funcionario) 
    SELECT id_funcionario FROM funcionarios
    WHERE num_cc = 94324242;
INSERT INTO funcionarios_de_limpeza(id_funcionario) 
    SELECT id_funcionario FROM funcionarios
    WHERE num_cc = 69545435;
----------------------------------------------------------------
--funcionaios balcao
INSERT INTO funcionarios_de_balcao(id_funcionario) 
    SELECT id_funcionario FROM funcionarios
    WHERE num_cc = 45464541;
INSERT INTO funcionarios_de_balcao(id_funcionario) 
    SELECT id_funcionario FROM funcionarios
    WHERE num_cc = 65742432;
INSERT INTO funcionarios_de_balcao(id_funcionario) 
    SELECT id_funcionario FROM funcionarios
    WHERE num_cc = 57655465;
--------------------------------------------------------------------
--outros funcionarios
INSERT INTO outros_funcionarios(id_funcionario,desc_funcao) 
    SELECT id_funcionario,'Diretor' FROM funcionarios
    where num_cc = 45496542;
INSERT INTO outros_funcionarios(id_funcionario,desc_funcao) 
    SELECT id_funcionario,'Canalizador' FROM funcionarios
    where num_cc = 56463542;
INSERT INTO outros_funcionarios(id_funcionario,desc_funcao) 
    SELECT id_funcionario,'Eletricista' FROM funcionarios
    where num_cc = 96785674;
------------------------------------------------------------------------
--reservas
INSERT INTO reservas(id_cliente,data_reserva,num_hospedes)
    SELECT id_cliente,(TO_DATE('31/05/2022','dd/mm/yyyy')),2
    FROM clientes
    WHERE num_cc = 13424328;
INSERT INTO reservas(id_cliente,data_reserva,num_hospedes)
    SELECT id_cliente,(TO_DATE('25/05/2022','dd/mm/yyyy')),1
    FROM clientes
    WHERE num_cc = 45356452;
INSERT INTO reservas(id_cliente,data_reserva,num_hospedes)
    SELECT id_cliente,(TO_DATE('25/05/2022','dd/mm/yyyy')),2
    FROM clientes
    WHERE num_cc = 25435433;
INSERT INTO reservas(id_cliente,data_reserva,check_in,check_out,num_hospedes)
    SELECT id_cliente,(TO_DATE('20/02/2022','dd/mm/yyyy')),(TO_DATE('22/02/2022 16:24','dd/mm/yyyy hh24:mi')),(TO_DATE('26/02/2022 11:10','dd/mm/yyyy hh24:mi')),2
    FROM clientes
    WHERE num_cc = 41341414;
----------------------------------------------------------------------
--pagamentos
INSERT INTO pagamentos(id_reserva,tipo_pagamento,valor,data)
    VALUES(4,'Multibanco',55,(TO_DATE('26/02/2022 11:30','dd/mm/yyyy hh24:mi')));
-------------------------------------------------------------------------
--reservas online
INSERT INTO reservas_online(id_reserva,email) VALUES(3,'abc123@gmail.com');
---------------------------------------------------------------------------
--reservas balcao
INSERT INTO reservas_balcao(id_reserva,id_funcionario) VALUES(2,4);
-------------------------------------------------------------------------
--tipos de quarto
INSERT INTO tipos_de_quarto(num_camas,descricao_tipo_quarto) 
    VALUES (2,'Quarto com duas camas individuais, uma mini-cozinha e uma casa de banho'); 
INSERT INTO tipos_de_quarto(num_camas,descricao_tipo_quarto) 
    VALUES (1,'Quarto com cama de casal e uma casa de banho');
INSERT INTO tipos_de_quarto(num_camas,descricao_tipo_quarto) 
    VALUES (1,'Quarto com cama individual e uma casa de banho');
INSERT INTO tipos_de_quarto(num_camas,descricao_tipo_quarto) 
    VALUES (2,'Quarto com cama de casal e uma cama individual , e com duas casas de banho');
---------------------------------------------------------------------------------
--quartos
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        2,2,25,'Quarto adequado para casais'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        2,2,27,'Quarto adequado para casais'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        2,3,35,'Quarto adequado para casais'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        4,2,20,'Quarto adequado para casais e mais com espaço para mais 1'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        1,2,21,'Quarto adequado para amigos'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        1,2,27,'Quarto adequado para uma pessoa'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        1,2,29,'Quarto adequado para uma pessoa'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        1,2,23,'Quarto adequado para uma pessoa'
    );
INSERT INTO QUARTOS(id_tipo_quarto,andar,numero_quarto,descricao)
    VALUES(
        1,2,22,'Quarto adequado para uma pessoa'
    );
----------------------------------------------------------------------------------------------
---preços quarto
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        1,(TO_DATE('25/05/2022','dd/mm/yyyy')),25,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        1,(TO_DATE('12/02/2022','dd/mm/yyyy')),30,'N'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        2,(TO_DATE('14/04/2022','dd/mm/yyyy')),30,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        3,(TO_DATE('15/04/2022','dd/mm/yyyy')),32,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        4,(TO_DATE('14/04/2022','dd/mm/yyyy')),30,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        5,(TO_DATE('14/04/2022','dd/mm/yyyy')),30,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        6,(TO_DATE('29/11/2020','dd/mm/yyyy')),22,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        7,(TO_DATE('14/04/2022','dd/mm/yyyy')),30,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        8,(TO_DATE('01/04/2021','dd/mm/yyyy')),30,'Y'
    );
INSERT INTO PRECOS_QUARTO(id_quarto, dia_inicio_valor,preco, preco_esta_ativo)
    VALUES(
        9,(TO_DATE('01/04/2021','dd/mm/yyyy')),30,'Y'
    );
----------------------------------------------------------------------------------------------
---estados quartos
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        1,'Ocupado','N'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        2,'Casa de banho com problemas','N'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        3,'À espera de limepza','N'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        4,'Limpo','Y'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        5,'Limpo','Y'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        6,'Limpo','Y'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        7,'Limpo','Y'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        8,'Limpo','Y'
    );
INSERT INTO ESTADOS_QUARTOS(id_quarto, descricao_estado,pronto_para_utilizar)
    VALUES(
        9,'Limpo','Y'
    );
----------------------------------------------------------------------------------------------
---limpezas quartos
INSERT INTO LIMPEZAS_QUARTOS(id_quarto,id_funcionario,dia,horas_inicio,horas_fim)
    VALUES(
        1,1,(TO_DATE('14/04/2022','dd/mm/yyyy')),10,11
    );
INSERT INTO LIMPEZAS_QUARTOS(id_quarto,id_funcionario,dia,horas_inicio,horas_fim)
    VALUES(
        1,2,(TO_DATE('15/04/2022','dd/mm/yyyy')),9,10
    );
INSERT INTO LIMPEZAS_QUARTOS(id_quarto,id_funcionario,dia,horas_inicio,horas_fim)
    VALUES(
        1,3,(TO_DATE('17/04/2022','dd/mm/yyyy')),10,11
    );
INSERT INTO LIMPEZAS_QUARTOS(id_quarto,id_funcionario,dia,horas_inicio,horas_fim)
    VALUES(
        2,3,(TO_DATE('24/05/2022','dd/mm/yyyy')),11,12
    );
INSERT INTO LIMPEZAS_QUARTOS(id_quarto,id_funcionario,dia,horas_inicio,horas_fim)
    VALUES(
        3,2,(TO_DATE('24/05/2022','dd/mm/yyyy')),11,12
    );
----------------------------------------------------------------------------------------------
---quartos reservados
INSERT ALL 
    INTO quartos_reservados(id_reserva, id_quarto, num_quarto_reserva)
        VALUES(4,6,1)
    INTO quartos_reservados(id_reserva, id_quarto, num_quarto_reserva)
        VALUES(4,7,2)
SELECT 1 FROM DUAL;

