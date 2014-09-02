SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS versao_dados;
CREATE TABLE versao_dados (
  id int(11) NOT NULL AUTO_INCREMENT,
  versaoUpdate BIGINT NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS despesa;
CREATE TABLE despesa (
  txNomeParlamentar varchar(100) DEFAULT NULL,
  nuCarteiraParlamentar int(11) DEFAULT NULL,
  nuLegislatura int(11) DEFAULT NULL,
  sgUF varchar(45) DEFAULT NULL,
  sgPartido varchar(45) DEFAULT NULL,
  codLegislatura int(11) DEFAULT NULL,
  numSubCota int(11) DEFAULT NULL,
  txtDescricao varchar(100) DEFAULT NULL,
  numEspecificacaoSubCota int(11) DEFAULT NULL,
  txtDescricaoEspecificacao varchar(100) DEFAULT NULL,
  txtBeneficiario varchar(100) DEFAULT NULL,
  txtCNPJCPF varchar(45) DEFAULT NULL,
  txtNumero int(11) DEFAULT NULL,
  indTipoDocumento int(11) DEFAULT NULL,
  datEmissao datetime DEFAULT NULL,
  vlrDocumento decimal(13,2) DEFAULT NULL,
  vlrGlosa decimal(13,2) DEFAULT NULL,
  vlrLiquido decimal(13,2) DEFAULT NULL,
  numMes int(11) DEFAULT NULL,
  numAno int(11) DEFAULT NULL,
  numParcela int(11) DEFAULT NULL,
  numLote int(11) DEFAULT NULL,
  numRessarcimento int(11) DEFAULT NULL,
  ideCadastro int(11) DEFAULT NULL,
  idDespesa int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (idDespesa),
  INDEX `idx_numAno` (numAno),
  INDEX `idx_ideCadastro` (ideCadastro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS parlamentar;
CREATE TABLE parlamentar (
  idParlamentar int(11) NOT NULL,
  nomeParlamentar varchar(100) NOT NULL,
  partidoParlamentar varchar(45) DEFAULT NULL,
  ufParlamentar varchar(45) NOT NULL,
  valor decimal(13,2) DEFAULT NULL,
  ranking int(11) DEFAULT NULL,
  PRIMARY KEY (idParlamentar),
  INDEX `idx_ranking` (ranking)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS parlamentar_tmp;
CREATE TABLE parlamentar_tmp (
  idParlamentar int(11) NOT NULL,
  nomeParlamentar varchar(100) NOT NULL,
  partidoParlamentar varchar(45) DEFAULT NULL,
  ufParlamentar varchar(45) NOT NULL,
  valor decimal(13,2) DEFAULT NULL,
  ranking int(11) DEFAULT NULL,
  PRIMARY KEY (idParlamentar),
  INDEX `idx_ranking` (ranking)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS cota;
CREATE TABLE cota (
  idCota bigint(11) DEFAULT NULL,
  idParlamentar int(11) NOT NULL,
  mes int(11) DEFAULT NULL,
  ano int(11) DEFAULT NULL,
  numSubcota int(11) DEFAULT NULL,
  descricao varchar(100) DEFAULT NULL,
  valor decimal(13,2) DEFAULT NULL,
  versaoUpdate int(11) DEFAULT NULL,
  PRIMARY KEY (idCota),
  FOREIGN KEY (idParlamentar) REFERENCES parlamentar(idParlamentar),
  INDEX `idx_ano` (ano)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS cota_tmp;
CREATE TABLE cota_tmp (
  idCota bigint(11) NOT NULL,
  idParlamentar int(11) DEFAULT NULL,
  mes int(11) DEFAULT NULL,
  ano int(11) DEFAULT NULL,
  numSubcota int(11) DEFAULT NULL,
  descricao varchar(100) DEFAULT NULL,
  valor decimal(13,2) DEFAULT NULL,
  versaoUpdate int(11) DEFAULT NULL,
  PRIMARY KEY (idCota),
  FOREIGN KEY (idParlamentar) REFERENCES parlamentar_tmp(idParlamentar),
  INDEX `idx_ano` (ano)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS=1;

DELIMITER $$ 

DROP FUNCTION IF EXISTS SomaCotaAtualParlamentar$$
CREATE FUNCTION SomaCotaAtualParlamentar(idParlamentar INT(11)) RETURNS decimal(13,2)
NOT DETERMINISTIC
BEGIN 
    DECLARE somaCotaAtual decimal(13,2);
    SELECT 
        SUM(d.vlrLiquido)
    INTO  somaCotaAtual
    FROM despesa d
    WHERE 
        d.numAno = YEAR(NOW())
        AND ideCadastro = idParlamentar;

    RETURN COALESCE(somaCotaAtual, 0);
END $$ 

DROP FUNCTION IF EXISTS AnoLegislaturaAtual$$
CREATE FUNCTION AnoLegislaturaAtual() RETURNS INT(11)
NOT DETERMINISTIC
BEGIN 
DECLARE anoLegislaturaAtual INT(11);
DECLARE anoAtual INT(11);	

SET anoAtual = YEAR(NOW());
SET anoLegislaturaAtual =  2011 + (4 * FLOOR(((anoAtual - 2011) / 4)));

RETURN anoLegislaturaAtual;
END $$ 

DROP PROCEDURE IF EXISTS CarregaTabelaParlamentar$$
CREATE PROCEDURE CarregaTabelaParlamentar() 
BEGIN 
    INSERT INTO parlamentar
    (SELECT 
        T.idParlamentar,
        T.txNomeParlamentar,
        T.sgPartido,
        T.sgUF,
        T.valor,
        0 AS ranking
    FROM
        (SELECT 
            ideCadastro AS idParlamentar,
            txNomeParlamentar,
            sgPartido,
            sgUF,
            0 AS valor
        FROM despesa
        WHERE 
            numAno >= AnoLegislaturaAtual()
            AND ideCadastro IS NOT NULL 
            AND ideCadastro != 0
        GROUP BY ideCadastro
        ORDER BY valor DESC 
    ) T);

    UPDATE parlamentar
    SET valor = SomaCotaAtualParlamentar(idParlamentar);

    UPDATE parlamentar
    JOIN (
        SELECT 
        idParlamentar,
        @ranking := @ranking + 1 AS ranking
        FROM parlamentar
        JOIN (SELECT @ranking := 0) r
        ORDER BY valor DESC 
     ) ranks ON (ranks.idParlamentar = parlamentar.idParlamentar)
    SET parlamentar.ranking = ranks.ranking;

END $$ 

DROP PROCEDURE IF EXISTS CarregaTabelaParlamentarTmp$$
CREATE PROCEDURE CarregaTabelaParlamentarTmp() 
BEGIN 
    INSERT INTO parlamentar_tmp
    (SELECT 
        T.idParlamentar,
        T.txNomeParlamentar,
        T.sgPartido,
        T.sgUF,
        T.valor,
        0 AS ranking
    FROM
        (SELECT 
            ideCadastro AS idParlamentar,
            txNomeParlamentar,
            sgPartido,
            sgUF,
            0 AS valor
        FROM despesa
        WHERE 
            numAno >= AnoLegislaturaAtual()
            AND ideCadastro IS NOT NULL 
            AND ideCadastro != 0
        GROUP BY ideCadastro
        ORDER BY valor DESC 
    ) T);

    UPDATE parlamentar_tmp
    SET valor = SomaCotaAtualParlamentar(idParlamentar);

    UPDATE parlamentar_tmp
    JOIN (
        SELECT 
        idParlamentar,
        @ranking := @ranking + 1 AS ranking
        FROM parlamentar_tmp
        JOIN (SELECT @ranking := 0) r
        ORDER BY valor DESC 
     ) ranks ON (ranks.idParlamentar = parlamentar_tmp.idParlamentar)
    SET parlamentar_tmp.ranking = ranks.ranking;

END $$

DROP PROCEDURE IF EXISTS CarregaTabelaCota$$
CREATE PROCEDURE CarregaTabelaCota() 
BEGIN
    UPDATE despesa
    SET numSubCota = 15
    WHERE numSubCota IN (120, 121, 122, 123);

    UPDATE despesa
    SET numSubCota = 9
    WHERE numSubCota = 999;

    INSERT INTO cota
    (SELECT 
        CONCAT(ideCadastro, numMes, numAno, numSubCota) AS idCota,
        ideCadastro AS idParlamentar,
        numMes,
        numAno,
        numSubCota,
        txtDescricao,
        SUM(vlrLiquido) AS valor,
        0
    FROM despesa
    WHERE 
        numAno >= AnoLegislaturaAtual()
        AND ideCadastro IS NOT NULL 
        AND ideCadastro != 0
    GROUP BY idCota
    );
END $$

DROP PROCEDURE IF EXISTS CarregaTabelaCotaTmp$$
CREATE PROCEDURE CarregaTabelaCotaTmp() 
BEGIN
    UPDATE despesa
    SET numSubCota = 15
    WHERE numSubCota IN (120, 121, 122, 123);

    UPDATE despesa
    SET numSubCota = 9
    WHERE numSubCota = 999; 
    
    INSERT INTO cota_tmp
    (SELECT 
        CONCAT(ideCadastro, numMes, numAno, numSubCota) AS idCota,
        ideCadastro AS idParlamentar,
        numMes,
        numAno,
        numSubCota,
        txtDescricao,
        SUM(vlrLiquido) AS valor,
        0
    FROM despesa
    WHERE 
        numAno >= AnoLegislaturaAtual()
        AND ideCadastro IS NOT NULL 
        AND ideCadastro != 0
    GROUP BY idCota
    );
END $$


DROP PROCEDURE IF EXISTS AtualizaInformacoes$$
CREATE PROCEDURE AtualizaInformacoes() 
BEGIN 
    UPDATE cota_tmp
    JOIN cota
    ON (cota_tmp.idCota = cota.idCota)
    SET cota_tmp.versaoUpdate = cota.versaoUpdate+1
    WHERE cota_tmp.valor != cota.valor;

    SET FOREIGN_KEY_CHECKS=0;
    TRUNCATE cota;
    TRUNCATE parlamentar;
    SET FOREIGN_KEY_CHECKS=1;

    INSERT INTO parlamentar
    (SELECT * from parlamentar_tmp);

    INSERT INTO cota
    (SELECT * from cota_tmp);

    SET FOREIGN_KEY_CHECKS=0;
    TRUNCATE cota_tmp;
    TRUNCATE parlamentar_tmp;
    SET FOREIGN_KEY_CHECKS=1;

    SET SQL_SAFE_UPDATES=0;

    UPDATE versao_dados
    SET versaoUpdate = versaoUpdate+1;

    SET SQL_SAFE_UPDATES=1;
END $$

DROP PROCEDURE IF EXISTS InicializaTabelaVersaoDados$$
CREATE PROCEDURE InicializaTabelaVersaoDados() 
BEGIN 
    INSERT INTO versao_dados 
    (versaoUpdate)
    VALUES 
    (1);
END $$


DELIMITER ;