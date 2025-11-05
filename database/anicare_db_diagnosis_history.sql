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
-- Table structure for table `diagnosis_history`
--

DROP TABLE IF EXISTS `diagnosis_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnosis_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vet_id` int NOT NULL,
  `user_id` int NOT NULL,
  `pet_name` varchar(100) DEFAULT NULL,
  `diagnosis` text,
  `treatment` text,
  `visit_date` date DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `vet_id` (`vet_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `diagnosis_history_ibfk_1` FOREIGN KEY (`vet_id`) REFERENCES `users` (`id`),
  CONSTRAINT `diagnosis_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diagnosis_history`
--

LOCK TABLES `diagnosis_history` WRITE;
/*!40000 ALTER TABLE `diagnosis_history` DISABLE KEYS */;
INSERT INTO `diagnosis_history` VALUES (4,2,1,'Buddy','Fever','Antibiotics','2025-08-28','Responding well','2025-09-01 11:06:46'),(5,2,5,'Milo','Sprained leg','Rest and bandage','2025-08-27','Follow-up in 1 week','2025-09-01 11:06:46'),(6,7,6,'Luna','Diarrhea','Probiotics','2025-08-28','Monitor diet','2025-09-01 11:06:46'),(7,7,4,'Charlie','Cough','Cough syrup','2025-08-26','Needs rest','2025-09-01 11:06:46'),(8,2,1,'Max','Allergy','Antihistamine','2025-08-25','Check skin daily','2025-09-01 11:06:46');
/*!40000 ALTER TABLE `diagnosis_history` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-19 12:34:57
