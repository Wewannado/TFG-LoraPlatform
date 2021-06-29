-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema IOT_Platform
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `IOT_Platform` ;

-- -----------------------------------------------------
-- Schema IOT_Platform
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `IOT_Platform` DEFAULT CHARACTER SET utf8 ;
USE `IOT_Platform` ;

-- -----------------------------------------------------
-- Table `IOT_Platform`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`users` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `password` VARCHAR(60) NOT NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`device`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`device` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`device` (
  `device_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `user_id` INT NOT NULL,
  `deviceHWadr` VARCHAR(16) NULL,
  `lastSeen` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  `downlinkURL` VARCHAR(200) NULL,
  `ttndev_id` VARCHAR(45) NULL,
  PRIMARY KEY (`device_id`, `user_id`),
  INDEX `fk_device_users_idx` (`user_id` ASC) VISIBLE,
  UNIQUE INDEX `iddevice_UNIQUE` (`device_id` ASC) VISIBLE,
  UNIQUE INDEX `deviceEUID_UNIQUE` (`deviceHWadr` ASC) VISIBLE,
  INDEX `deviceHWadr` (`deviceHWadr` ASC) VISIBLE,
  CONSTRAINT `fk_device_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `IOT_Platform`.`users` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`SensorTypes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`SensorTypes` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`SensorTypes` (
  `idTypes` INT NOT NULL,
  `sensorTypeName` VARCHAR(45) NULL,
  PRIMARY KEY (`idTypes`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`sensors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`sensors` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`sensors` (
  `idsensor` INT NOT NULL AUTO_INCREMENT,
  `SensorName` VARCHAR(45) NULL,
  `device_port` INT(1) NOT NULL,
  `device_id` INT NOT NULL,
  `SensorType` INT NOT NULL,
  PRIMARY KEY (`device_port`, `device_id`),
  INDEX `fk_sensors_device1_idx` (`device_id` ASC) VISIBLE,
  UNIQUE INDEX `idsensors_UNIQUE` (`idsensor` ASC) VISIBLE,
  INDEX `fk_sensors_SensorTypes1_idx` (`SensorType` ASC) VISIBLE,
  CONSTRAINT `fk_sensors_device1`
    FOREIGN KEY (`device_id`)
    REFERENCES `IOT_Platform`.`device` (`device_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sensors_SensorTypes1`
    FOREIGN KEY (`SensorType`)
    REFERENCES `IOT_Platform`.`SensorTypes` (`idTypes`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`sensor_Data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`sensor_Data` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`sensor_Data` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `data` VARCHAR(45) NULL,
  `dataType` VARCHAR(45) NULL,
  `sensors_idsensors` INT NOT NULL,
  PRIMARY KEY (`id`, `sensors_idsensors`),
  INDEX `fk_sensor_Data_sensors1_idx` (`sensors_idsensors` ASC) VISIBLE,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  CONSTRAINT `fk_sensor_Data_sensors1`
    FOREIGN KEY (`sensors_idsensors`)
    REFERENCES `IOT_Platform`.`sensors` (`idsensor`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`TriggerOperations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`TriggerOperations` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`TriggerOperations` (
  `idTriggerOperations` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`idTriggerOperations`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`disparadors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`disparadors` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`disparadors` (
  `trigger_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `name` VARCHAR(45) NULL,
  `input_sensor` INT NOT NULL,
  `operator` INT NOT NULL,
  `operationValue` VARCHAR(45) NULL,
  `output_sensor` INT NOT NULL,
  `outputValue` VARCHAR(45) NULL,
  PRIMARY KEY (`trigger_id`),
  INDEX `fk_triggers_TriggerOperations1_idx` (`operator` ASC) VISIBLE,
  INDEX `fk_triggers_users1_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_triggers_sensors1_idx` (`input_sensor` ASC) VISIBLE,
  INDEX `fk_triggers_sensors2_idx` (`output_sensor` ASC) VISIBLE,
  CONSTRAINT `fk_triggers_TriggerOperations1`
    FOREIGN KEY (`operator`)
    REFERENCES `IOT_Platform`.`TriggerOperations` (`idTriggerOperations`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_triggers_users1`
    FOREIGN KEY (`user_id`)
    REFERENCES `IOT_Platform`.`users` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_triggers_sensors1`
    FOREIGN KEY (`input_sensor`)
    REFERENCES `IOT_Platform`.`sensors` (`idsensor`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_triggers_sensors2`
    FOREIGN KEY (`output_sensor`)
    REFERENCES `IOT_Platform`.`sensors` (`idsensor`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`user_alerts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`user_alerts` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`user_alerts` (
  `device_device_id` INT NOT NULL,
  `device_user_id` INT NOT NULL,
  `triggered` TINYINT NULL DEFAULT 0,
  `trigger_timer` INT(10) NULL,
  INDEX `fk_user_alerts_device1_idx` (`device_device_id` ASC, `device_user_id` ASC) VISIBLE,
  PRIMARY KEY (`device_device_id`, `device_user_id`),
  CONSTRAINT `fk_user_alerts_device1`
    FOREIGN KEY (`device_device_id` , `device_user_id`)
    REFERENCES `IOT_Platform`.`device` (`device_id` , `user_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `IOT_Platform`.`triggerQueue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IOT_Platform`.`triggerQueue` ;

CREATE TABLE IF NOT EXISTS `IOT_Platform`.`triggerQueue` (
  `idtriggerQueue` INT NOT NULL AUTO_INCREMENT,
  `disparadors_trigger_id` INT NOT NULL,
  PRIMARY KEY (`idtriggerQueue`, `disparadors_trigger_id`),
  UNIQUE INDEX `idtriggerQueue_UNIQUE` (`idtriggerQueue` ASC) VISIBLE,
  INDEX `fk_triggerQueue_disparadors1_idx` (`disparadors_trigger_id` ASC) VISIBLE,
  UNIQUE INDEX `disparadors_trigger_id_UNIQUE` (`disparadors_trigger_id` ASC) VISIBLE,
  CONSTRAINT `fk_triggerQueue_disparadors1`
    FOREIGN KEY (`disparadors_trigger_id`)
    REFERENCES `IOT_Platform`.`disparadors` (`trigger_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
