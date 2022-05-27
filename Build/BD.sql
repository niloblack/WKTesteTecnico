CREATE DATABASE db_wktechnolog;
USE db_wktechnolog;

CREATE TABLE tb_clientes (
	codigo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL,
    cidade VARCHAR(60),
    uf CHAR(2),
    KEY idx_clientes_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_produtos (
	codigo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(60) NOT NULL,
    preco_venda DOUBLE(15, 2),
    KEY idx_produtos_descricao (descricao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_pedidos (
	numero INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    data_emissao DATE NOT NULL,
    codigo_cliente INT NOT NULL,
    valor_total DOUBLE(15, 2),
    KEY idx_pedidos_codigo_cliente (codigo_cliente),
    KEY idx_pedidos_data_emissao (data_emissao),
   CONSTRAINT fk_pedidos_codigo_cliente FOREIGN KEY (codigo_cliente) REFERENCES tb_clientes (codigo) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_itens_pedidos (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    numero_pedido INT NOT NULL,
    codigo_produto INT NOT NULL,
    quantidade DOUBLE(15, 4),
    valor_unitario DOUBLE(15, 6),
    valor_total DOUBLE(15, 2),
    KEY idx_itens_pedidos_numero_pedido (numero_pedido),
    KEY idx_itens_pedidos_codigo_produto (codigo_produto),
    CONSTRAINT fk_itens_pedidos_numero_pedido FOREIGN KEY (numero_pedido) REFERENCES tb_pedidos (numero) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_itens_pedidos_codigo_produto FOREIGN KEY (codigo_produto) REFERENCES tb_produtos (codigo) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO tb_clientes (nome, cidade, uf) VALUES 
('Danilo Ângelo', 'Limoeiro', 'PE'),
('Joyce Machado', 'Carpina', 'PE'),
('Maisa Silva', 'Caruaru', 'PE'),
('Larissa Manoela', 'Recife', 'PE'),
('Gusttavo Lima', 'Florianópolis', 'SC'),
('Bruna Silva', 'Curitiba', 'PR'),
('Alan Werneck', 'Rio de Janeiro', 'RJ'),
('Marcelo Vieira', 'Natal', 'RN'),
('Ronaldo Aragão', 'Fortaleza', 'CE'),
('Janaina Karla', 'João Pessoa', 'PB'),
('Francisco Everardo', 'Maceió', 'AL'),
('Erineide Martins', 'Penedo', 'AL'),
('Gustavo Caetano', 'Salvador', 'BA'),
('Arthur Peregrino', 'Belo Horizonte', 'MG'),
('Maria Ângela', 'São Paulo', 'SP'),
('Augusto Nicodemus', 'Porto Alegre', 'RS'),
('Max Lucado', 'Gramado', 'RS'),
('Mario Sérgio', 'Brasília', 'DF'),
('Gabriela Souza', 'Manaus', 'AM'),
('Jenniffer Lopes', 'Palmas', 'TO');


INSERT INTO tb_produtos (descricao, preco_venda) VALUES 
('Produto 001', 1.58),
('Produto 002', 2.00),
('Produto 003', 3.01),
('Produto 004', 4.14),
('Produto 005', 5.22),
('Produto 006', 6.34),
('Produto 007', 7.91),
('Produto 008', 8.99),
('Produto 009', 9.10),
('Produto 010', 10.12),
('Produto 011', 11.23),
('Produto 012', 12.32),
('Produto 013', 13.13),
('Produto 014', 14.58),
('Produto 015', 15.22),
('Produto 016', 16.36),
('Produto 017', 17.48),
('Produto 018', 18.42),
('Produto 019', 19.49),
('Produto 020', 20.87);