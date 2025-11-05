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
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('pet_owner','vet','ngo') NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT IGNORE INTO `users` VALUES (1,'Riya Jagtap','riya@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(2,'Dr. Mehta','vet@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','vet',NULL),(4,'Riya','riya@user.com','scrypt:32768:8:1$WqW17mVhHfns5Guw$9baa86c84d16f01e1b2d3b586e4b92f737fb562db4b6fe10511b38d6d0912165ae885ec9fdd6cfd7f3fea5c3c951b4599c98eeb36a6062eb0696a76a20c965ce','pet_owner',NULL),(5,'Soham','user@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(6,'Sanika','sanika@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(7,'Gauri','gauri@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','vet',NULL),(8,'Tester','tester@example.com','scrypt:32768:8:1$MyvjdyDU$4efa0e38a905129e90c5b933533fb5bd67ead8c711538a715d83a2bac40ac0e5430121f1e97823c7aa71da44aec7ce3bff64004438a466ddd1bfea448984b6ed','pet_owner',NULL),(9,'NGO Test','ngo@example.com','scrypt:32768:8:1$VOW4A9MX$846162d95bb59ea7df13f097f9c6e5b301caf3a9cff2196f1d3688e50fc8a7d75c841d35191094ce9cf96c4b173d62b6b62952e9f4df19bcb297993d60128049','ngo',NULL),(10,'Paws & Claws Trust','pawstrust@example.com','scrypt:32768:8:1$ZfifO1S0$9d5a7a944e5338efee0137f163997224e372e0ab9f88de21ff3a9d5d4b0b646247b497ba91bf5b3f22a6d4f56445aad9cf3379b21ee77678a87f326a1bd297a8','ngo',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
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
