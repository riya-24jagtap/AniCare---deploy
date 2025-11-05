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
-- Table structure for table `vets`
--

DROP TABLE IF EXISTS `vets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `password` varchar(255) DEFAULT NULL,
  `clinic_address` varchar(255) DEFAULT NULL,
  `bio` text,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `working_start` time DEFAULT '10:00:00',
  `working_end` time DEFAULT '18:00:00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vets`
--

LOCK TABLES `vets` WRITE;
/*!40000 ALTER TABLE `vets` DISABLE KEYS */;
INSERT IGNORE INTO `vets` VALUES (8,'Sneha Shah','priya@example.com','+917390280068','cardiology','2025-09-01 11:54:48','2025-09-02 15:41:01','scrypt:32768:8:1$PFd6DSCZD17yzJrC$f2de2137bde2ed10cb727f209847d8d936b8cd441b2d2e3d5b9d60bf9368d39c328be0a5fc71e7b46a04dfad78efd0f1f16bbb64e9f3c9264225ac3b2c1126aa','123, Pet care lane, Mumbai','Dr. Sneha Shah, DVM – Veterinary Cardiologist\r\nDr. Sneha Shah is a board-certified veterinary cardiologist specializing in diagnosing and treating heart and circulatory disorders in pets. She uses advanced tools like echocardiography and ECG to provide personalized care, ensuring pets lead healthier, happier lives.',NULL,NULL,'10:00:00','18:00:00'),(9,'Sanika Patil','sanika@example.com','+917941858137','dermatology','2025-09-02 18:52:25','2025-09-02 18:57:37','scrypt:32768:8:1$HjEgSqMc$e4b16b106ce57ec04df42ee32d6f56f95574dc6fce59eba478d5dbb2c44fc6b3bcc42c007bb53c715a955d841972ff3cec981f191bf32cec1d84450aa22398e0','F, Guruprasad Divine Residency, 1B, Pt CR Vyas Marg, near Chembur, Swastik Park, Chembur, Mumbai, Maharashtra 400071','Dr. Sanika is a dedicated veterinary professional specializing in dermatology. She focuses on diagnosing and treating skin disorders, allergies, and coat-related conditions in pets, ensuring their comfort and overall well-being.',NULL,NULL,'10:00:00','18:00:00'),(10,'Soham','soham@example.com','','','2025-09-02 19:29:29','2025-09-02 19:29:29','scrypt:32768:8:1$HTzyHBj0$fccb4dd5ddb6630cf5f56fc49517e18f78e2538f6a252a432d756366f4cb6ef0589cc4f46add65953a68ba757e4dd27c5a91c5788f93e212a981451c6e2bb59b','',NULL,NULL,NULL,'10:00:00','18:00:00'),(13,'Tejal Wagh','tejal@example.com','','','2025-09-15 19:02:31',NULL,'scrypt:32768:8:1$ppCoW00j$3bdbfcde2e7f894ec20823cbc5f3f5ebe02ce5a317f95702863710d8c5beb3e824a7a4c45c5ef7ec7814cfa00e1af08b0ff5fc555a2373d6129c091b3f73334a','','',NULL,NULL,'10:00:00','18:00:00');
/*!40000 ALTER TABLE `vets` ENABLE KEYS */;
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
