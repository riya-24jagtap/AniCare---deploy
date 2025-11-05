-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: anicare_db
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `vet_appointments`
--

DROP TABLE IF EXISTS `vet_appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vet_appointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pet_id` int DEFAULT NULL,
  `vet_id` int DEFAULT NULL,
  `appointment_time` datetime DEFAULT NULL,
  `reason` text,
  `status` enum('scheduled','cancelled','done') NOT NULL DEFAULT 'scheduled',
  `pet_name` varchar(100) DEFAULT NULL,
  `pet_type` varchar(50) DEFAULT NULL,
  `vet_name` varchar(100) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pet_id` (`pet_id`),
  KEY `vet_id` (`vet_id`),
  CONSTRAINT `vet_appointments_ibfk_1` FOREIGN KEY (`pet_id`) REFERENCES `pet_records` (`id`),
  CONSTRAINT `vet_appointments_ibfk_2` FOREIGN KEY (`vet_id`) REFERENCES `vets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vet_appointments`
--

LOCK TABLES `vet_appointments` WRITE;
/*!40000 ALTER TABLE `vet_appointments` DISABLE KEYS */;
INSERT INTO `vet_appointments` VALUES (36,2,8,'2025-10-05 10:00:00','General Checkup','scheduled','Bruno','Dog','Sneha Shah',1),(37,NULL,9,'2025-10-05 11:00:00','Vaccination','scheduled','Mittens','Cat','Sanika Patil',NULL),(38,NULL,8,'2025-10-06 09:30:00','Skin Allergy','done','Charlie','Dog','Sneha Shah',NULL),(39,NULL,10,'2025-10-06 14:00:00','Dental Cleaning','scheduled','Bella','Cat','Soham',NULL),(40,NULL,9,'2025-10-07 10:30:00','Ear Infection','cancelled','Max','Dog','Sanika Patil',NULL),(41,NULL,13,'2025-10-07 15:00:00','Vaccination','done','Luna','Cat','Tejal Wagh',NULL),(42,1,13,'2025-10-04 11:00:00','Red patches on the skin','done','Tommy','dog','Tejal Wagh',1),(43,NULL,13,'2025-10-03 11:30:00','Fungal Infection','done','Buddy','Dog','Tejal Wagh',NULL),(44,2,8,'2025-10-12 15:00:00','Routine annual wellness exam and necessary vaccinations.','scheduled','Bruno','Dog','Sneha Shah',1),(45,2,9,'2025-10-12 09:30:00','annual health check up','scheduled','Bruno','Dog','Sanika Patil',1),(46,2,13,'2025-10-13 15:00:00','annual health checkup','done','Bruno','Dog','Tejal Wagh',1),(47,1,13,'2025-10-13 15:30:00','Routine screenings for blood pressure, cholesterol, sugar, etc.','scheduled','Tommy','Dog','Tejal Wagh',1);
/*!40000 ALTER TABLE `vet_appointments` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-05 15:38:09
