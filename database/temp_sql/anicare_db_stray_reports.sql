-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: anicare_db
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `stray_reports`
--

DROP TABLE IF EXISTS `stray_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stray_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ngo_id` int DEFAULT NULL,
  `animal_type` varchar(50) DEFAULT NULL,
  `description` text,
  `location` varchar(100) DEFAULT NULL,
  `reported_by` varchar(100) DEFAULT NULL,
  `report_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','in_progress','resolved') DEFAULT 'pending',
  `assigned_vet_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_stray_reports_ngo` (`ngo_id`),
  KEY `fk_stray_reports_vet` (`assigned_vet_id`),
  CONSTRAINT `fk_stray_reports_ngo` FOREIGN KEY (`ngo_id`) REFERENCES `ngo` (`id`),
  CONSTRAINT `fk_stray_reports_vet` FOREIGN KEY (`assigned_vet_id`) REFERENCES `vets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stray_reports`
--

LOCK TABLES `stray_reports` WRITE;
/*!40000 ALTER TABLE `stray_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `stray_reports` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-19 12:34:56
