CREATE TABLE IF NOT EXISTS `usuarios` (
  `id_usuario` INT AUTO_INCREMENT NOT NULL UNIQUE,
  `email` VARCHAR(320),
  `senha` VARCHAR(50),
  `flag_login_facebook` TINYINT NOT NULL DEFAULT 0,
  `flag_login_gmail` TINYINT NOT NULL DEFAULT 0,
  `id_oauth` VARCHAR(255),
  `token_oauth` TEXT,
  `nome_completo` VARCHAR(100) NOT NULL,
  `data_cadastro` DATETIME NOT NULL,
  `flag_ativo` TINYINT NOT NULL DEFAULT 0,
  `flag_deletado` TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_usuario`)
);

CREATE TABLE IF NOT EXISTS `pacientes` (
  `id_usuario` INT NOT NULL UNIQUE,
  `url_foto` VARCHAR(255),
  `data_nascimento` DATETIME,
  `cpf` CHAR(11),
  `desc_genero` VARCHAR(100),
  `cidade` VARCHAR(50),
  `sigla_estado` CHAR(2),
  `whatsapp` CHAR(11),
  `possui_deficiencia` TINYINT NOT NULL DEFAULT 0,
  `desc_deficiencias` VARCHAR(500),
  `precisa_assist_legal` TINYINT NOT NULL DEFAULT 0,
  `usa_medicamento` TINYINT NOT NULL DEFAULT 0,
  `desc_medicamentos` VARCHAR(500),
  `id_diagnostico` INT,
  `filename_diagnostico` VARCHAR(200),
  PRIMARY KEY (`id_usuario`)
);

CREATE TABLE IF NOT EXISTS `profissionais` (
  `id_usuario` INT NOT NULL UNIQUE,
  `desc_funcao` VARCHAR(100),
  PRIMARY KEY (`id_usuario`)
);

CREATE TABLE IF NOT EXISTS `diagnosticos` (
  `id_diagnostico` INT NOT NULL UNIQUE,
  `desc_diagnostico` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`id_diagnostico`)
);

CREATE TABLE IF NOT EXISTS `apoios` (
  `id_apoio` INT AUTO_INCREMENT NOT NULL UNIQUE,
  `id_usuario` INT NOT NULL,
  `nome_apoio` VARCHAR(100) NOT NULL,
  `parentesco` VARCHAR(100) NOT NULL,
  `whatsapp` VARCHAR(11) NOT NULL,
  PRIMARY KEY (`id_apoio`)
);

CREATE TABLE IF NOT EXISTS `log_alteracoes` (
  `id_alteracao` INT AUTO_INCREMENT NOT NULL UNIQUE,
  `id_usuario_autor` INT NOT NULL,
  `id_usuario_alvo` INT,
  `data_hora` DATETIME NOT NULL,
  `descricao` VARCHAR(500) NOT NULL,
  PRIMARY KEY (`id_alteracao`)
);

CREATE TABLE IF NOT EXISTS `atendimentos` (
  `id_atendimento` INT AUTO_INCREMENT NOT NULL UNIQUE,
  `id_usuario` INT NOT NULL,
  `data_hora` DATETIME NOT NULL,
  `flag_status_surto` TINYINT NOT NULL,
  `observacoes` VARCHAR(500) NOT NULL,
  PRIMARY KEY (`id_atendimento`)
);


DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS AddForeignKeyIfNotExists(
    IN tableName VARCHAR(64),
    IN constraintName VARCHAR(64),
    IN foreignKeyColumn VARCHAR(64),
    IN referenceTable VARCHAR(64),
    IN referenceColumn VARCHAR(64)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_NAME = constraintName
          AND TABLE_NAME = tableName
    ) THEN
        SET @alterSQL = CONCAT(
            'ALTER TABLE ', tableName,
            ' ADD CONSTRAINT ', constraintName,
            ' FOREIGN KEY (', foreignKeyColumn, ') REFERENCES ', referenceTable, '(', referenceColumn, ')'
        );
        PREPARE stmt FROM @alterSQL;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END $$

DELIMITER ;


CALL AddForeignKeyIfNotExists('pacientes', 'pacientes_fk0', 'id_usuario', 'usuarios', 'id_usuario');
CALL AddForeignKeyIfNotExists('pacientes', 'pacientes_fk13', 'id_diagnostico', 'diagnosticos', 'id_diagnostico');

CALL AddForeignKeyIfNotExists('profissionais', 'profissionais_fk0', 'id_usuario', 'usuarios', 'id_usuario');

CALL AddForeignKeyIfNotExists('apoios', 'apoios_fk1', 'id_usuario', 'pacientes', 'id_usuario');

CALL AddForeignKeyIfNotExists('log_alteracoes', 'log_alteracoes_fk1', 'id_usuario_autor', 'usuarios', 'id_usuario');
CALL AddForeignKeyIfNotExists('log_alteracoes', 'log_alteracoes_fk2', 'id_usuario_alvo', 'usuarios', 'id_usuario');

CALL AddForeignKeyIfNotExists('atendimentos', 'atendimentos_fk1', 'id_usuario', 'pacientes', 'id_usuario');
