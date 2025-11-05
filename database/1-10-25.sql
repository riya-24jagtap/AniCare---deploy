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
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vet_id` int NOT NULL,
  `user_id` int NOT NULL,
  `pet_name` varchar(100) DEFAULT NULL,
  `appointment_date` date DEFAULT NULL,
  `appointment_time` time DEFAULT NULL,
  `reason` text,
  `status` enum('Pending','Approved','Rejected','Completed') DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `vet_id` (`vet_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`vet_id`) REFERENCES `users` (`id`),
  CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cases`
--

DROP TABLE IF EXISTS `cases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cases` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ngo_id` int DEFAULT NULL,
  `status` enum('open','pending','resolved') NOT NULL DEFAULT 'open',
  `description` text,
  `assigned_vet_id` int DEFAULT NULL,
  `animal_type` varchar(50) NOT NULL DEFAULT 'Unknown',
  `location` varchar(100) DEFAULT NULL,
  `reported_by` int DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cases_ngo` (`ngo_id`),
  KEY `fk_assigned_vet` (`assigned_vet_id`),
  CONSTRAINT `fk_assigned_vet` FOREIGN KEY (`assigned_vet_id`) REFERENCES `vets` (`id`),
  CONSTRAINT `fk_cases_ngo` FOREIGN KEY (`ngo_id`) REFERENCES `ngo` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cases`
--

LOCK TABLES `cases` WRITE;
/*!40000 ALTER TABLE `cases` DISABLE KEYS */;
/*!40000 ALTER TABLE `cases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consultation_history`
--

DROP TABLE IF EXISTS `consultation_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `consultation_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vet_id` int NOT NULL,
  `pet_id` int NOT NULL,
  `diagnosis` text NOT NULL,
  `treatment` text NOT NULL,
  `visit_date` date NOT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_consultation_vet` (`vet_id`),
  KEY `fk_consultation_pet` (`pet_id`),
  CONSTRAINT `fk_consultation_pet` FOREIGN KEY (`pet_id`) REFERENCES `pet_records` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_consultation_vet` FOREIGN KEY (`vet_id`) REFERENCES `vets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consultation_history`
--

LOCK TABLES `consultation_history` WRITE;
/*!40000 ALTER TABLE `consultation_history` DISABLE KEYS */;
INSERT INTO `consultation_history` VALUES (2,8,1,'Fever and weakness','Antibiotics prescribed','2025-09-02','Follow-up in 5 days','2025-09-01 20:34:20');
/*!40000 ALTER TABLE `consultation_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role` enum('vet','ngo','user') NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
INSERT INTO `contact_messages` VALUES (1,'vet','Riya Test','riya@example.com','Test Subject','Testing contact page','2025-09-18 18:40:29'),(2,'ngo','Ruchi Suresh Jagtap','ruchijagtap.2023@gmail.com','collaboration','Request about collaboration with my PetPal NGO','2025-09-18 18:57:46'),(3,'user','Soham Suresh Jagtap','soham@example.com','collaboration','Wanted to enquire about the volunteer start date &  timings','2025-09-18 19:03:51'),(4,'vet','Aditi Suresh Jagtap','aditi@example.com','collaboration','Starting a new vet clinic at Bandra, thinking of collaborating with your organization','2025-09-18 19:17:55'),(5,'vet','Jyoti Suresh Jagtap','jyoti@example.com','general','I have a question about my parrot and would appreciate some information on vaccine to be given.','2025-09-18 19:23:32'),(6,'user','Riya Suresh Jagtap','riyajagtap.2023@gmail.com','general','hello world...','2025-09-19 05:47:45');
/*!40000 ALTER TABLE `contact_messages` ENABLE KEYS */;
UNLOCK TABLES;

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

--
-- Table structure for table `donations`
--

DROP TABLE IF EXISTS `donations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `amount` float NOT NULL,
  `date` date NOT NULL,
  `message` text,
  `ngo_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ngo_id` (`ngo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donations`
--

LOCK TABLES `donations` WRITE;
/*!40000 ALTER TABLE `donations` DISABLE KEYS */;
INSERT INTO `donations` VALUES (1,'Alice',1000,'2025-08-12','Keep up the great work!',3);
/*!40000 ALTER TABLE `donations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `donors`
--

DROP TABLE IF EXISTS `donors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ngo_id` int NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `donation_date` date DEFAULT NULL,
  `message` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donors`
--

LOCK TABLES `donors` WRITE;
/*!40000 ALTER TABLE `donors` DISABLE KEYS */;
/*!40000 ALTER TABLE `donors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `message` text NOT NULL,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` VALUES (1,1,'This project shows genuine care for animals. Truly inspiring!','2025-09-18 21:47:45','Tejal Wagh ','tejal@example.com'),(2,NULL,'hello world \r\n','2025-09-19 05:48:44','Riya Suresh Jagtap','riyajagtap.2023@gmail.com');
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ngo`
--

DROP TABLE IF EXISTS `ngo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `role` enum('ngo','vet') NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(200) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `location` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ngo`
--

LOCK TABLES `ngo` WRITE;
/*!40000 ALTER TABLE `ngo` DISABLE KEYS */;
INSERT INTO `ngo` VALUES (17,'Bandra Animal Rescue','ngo','bandra.ngo@example.com','scrypt:32768:8:1$JQ68d51v$fcba2fbf78c5779156d94e04451ddcfc0fa30923ec10afcddf77d9e5bc368649899d119294a079f7c63f3a52d209f64b141aecf0af48d5acc9721d047f557bcb','+917390280068','Bandra Animal Rescue 123, Pali Hill Road, Opposite St. Peter\'s Church, Bandra West, Mumbai - 400050 Maharashtra, India','Bandra West, Mumbai','2025-09-16 02:27:00',NULL,NULL);
/*!40000 ALTER TABLE `ngo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pet_records`
--

DROP TABLE IF EXISTS `pet_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int DEFAULT NULL,
  `pet_name` varchar(100) DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `breed` varchar(50) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `medical_history` text,
  `vet_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `pet_records_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pet_records`
--

LOCK TABLES `pet_records` WRITE;
/*!40000 ALTER TABLE `pet_records` DISABLE KEYS */;
INSERT INTO `pet_records` VALUES (1,1,'Tommy','Dog','Labrador',3,NULL,1);
/*!40000 ALTER TABLE `pet_records` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `users` VALUES (1,'Riya Jagtap','riya@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(2,'Dr. Mehta','vet@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','vet',NULL),(4,'Riya','riya@user.com','scrypt:32768:8:1$WqW17mVhHfns5Guw$9baa86c84d16f01e1b2d3b586e4b92f737fb562db4b6fe10511b38d6d0912165ae885ec9fdd6cfd7f3fea5c3c951b4599c98eeb36a6062eb0696a76a20c965ce','pet_owner',NULL),(5,'Soham','user@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(6,'Sanika','sanika@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(7,'Gauri','gauri@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','vet',NULL),(8,'Tester','tester@example.com','scrypt:32768:8:1$MyvjdyDU$4efa0e38a905129e90c5b933533fb5bd67ead8c711538a715d83a2bac40ac0e5430121f1e97823c7aa71da44aec7ce3bff64004438a466ddd1bfea448984b6ed','pet_owner',NULL),(9,'NGO Test','ngo@example.com','scrypt:32768:8:1$VOW4A9MX$846162d95bb59ea7df13f097f9c6e5b301caf3a9cff2196f1d3688e50fc8a7d75c841d35191094ce9cf96c4b173d62b6b62952e9f4df19bcb297993d60128049','ngo',NULL),(10,'Paws & Claws Trust','pawstrust@example.com','scrypt:32768:8:1$ZfifO1S0$9d5a7a944e5338efee0137f163997224e372e0ab9f88de21ff3a9d5d4b0b646247b497ba91bf5b3f22a6d4f56445aad9cf3379b21ee77678a87f326a1bd297a8','ngo',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

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
  `status` enum('scheduled','completed','cancelled') DEFAULT 'scheduled',
  PRIMARY KEY (`id`),
  KEY `pet_id` (`pet_id`),
  KEY `vet_id` (`vet_id`),
  CONSTRAINT `vet_appointments_ibfk_1` FOREIGN KEY (`pet_id`) REFERENCES `pet_records` (`id`),
  CONSTRAINT `vet_appointments_ibfk_2` FOREIGN KEY (`vet_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vet_appointments`
--

LOCK TABLES `vet_appointments` WRITE;
/*!40000 ALTER TABLE `vet_appointments` DISABLE KEYS */;
/*!40000 ALTER TABLE `vet_appointments` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `vets` VALUES (8,'Sneha Shah','priya@example.com','+917390280068','cardiology','2025-09-01 11:54:48','2025-09-02 15:41:01','scrypt:32768:8:1$PFd6DSCZD17yzJrC$f2de2137bde2ed10cb727f209847d8d936b8cd441b2d2e3d5b9d60bf9368d39c328be0a5fc71e7b46a04dfad78efd0f1f16bbb64e9f3c9264225ac3b2c1126aa','123, Pet care lane, Mumbai','Dr. Sneha Shah, DVM – Veterinary Cardiologist\r\nDr. Sneha Shah is a board-certified veterinary cardiologist specializing in diagnosing and treating heart and circulatory disorders in pets. She uses advanced tools like echocardiography and ECG to provide personalized care, ensuring pets lead healthier, happier lives.',NULL,NULL,'10:00:00','18:00:00'),(9,'Sanika Patil','sanika@example.com','+917941858137','dermatology','2025-09-02 18:52:25','2025-09-02 18:57:37','scrypt:32768:8:1$HjEgSqMc$e4b16b106ce57ec04df42ee32d6f56f95574dc6fce59eba478d5dbb2c44fc6b3bcc42c007bb53c715a955d841972ff3cec981f191bf32cec1d84450aa22398e0','F, Guruprasad Divine Residency, 1B, Pt CR Vyas Marg, near Chembur, Swastik Park, Chembur, Mumbai, Maharashtra 400071','Dr. Sanika is a dedicated veterinary professional specializing in dermatology. She focuses on diagnosing and treating skin disorders, allergies, and coat-related conditions in pets, ensuring their comfort and overall well-being.',NULL,NULL,'10:00:00','18:00:00'),(10,'Soham','soham@example.com','','','2025-09-02 19:29:29','2025-09-02 19:29:29','scrypt:32768:8:1$HTzyHBj0$fccb4dd5ddb6630cf5f56fc49517e18f78e2538f6a252a432d756366f4cb6ef0589cc4f46add65953a68ba757e4dd27c5a91c5788f93e212a981451c6e2bb59b','',NULL,NULL,NULL,'10:00:00','18:00:00'),(13,'Tejal Wagh','tejal@example.com','','','2025-09-15 19:02:31',NULL,'scrypt:32768:8:1$ppCoW00j$3bdbfcde2e7f894ec20823cbc5f3f5ebe02ce5a317f95702863710d8c5beb3e824a7a4c45c5ef7ec7814cfa00e1af08b0ff5fc555a2373d6129c091b3f73334a','','',NULL,NULL,'10:00:00','18:00:00');
/*!40000 ALTER TABLE `vets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `volunteers`
--

DROP TABLE IF EXISTS `volunteers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `volunteers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `area` varchar(100) DEFAULT NULL,
  `joined_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('active','inactive') DEFAULT 'active',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ngo_id` int DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_volunteers_ngo` (`ngo_id`),
  CONSTRAINT `fk_volunteers_ngo` FOREIGN KEY (`ngo_id`) REFERENCES `ngo` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `volunteers`
--

LOCK TABLES `volunteers` WRITE;
/*!40000 ALTER TABLE `volunteers` DISABLE KEYS */;
/*!40000 ALTER TABLE `volunteers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-19 12:22:26


USE anicare_db;


SELECT * FROM vets;

SELECT * FROM vet_appointments;
DESC vet_appointments;
DESCRIBE vet_appointments;


ALTER TABLE vet_appointments 
ADD COLUMN pet_name VARCHAR(100),
ADD COLUMN pet_type VARCHAR(50);

INSERT INTO vet_appointments (vet_id, pet_id, appointment_time, reason, status)
VALUES (1, 1, NOW() + INTERVAL 1 HOUR, 'General Checkup', 'scheduled');

TRUNCATE table vet_appointments;

SELECT * FROM vet_appointments;

SELECT * FROM USERS;

SELECT * FROM feedback;
SELECT * FROM contact_messages;
DELETE FROM contact_messages WHERE ID = 5;

SELECT * FROM appointments;     -- vet dashboard's appointmnents table
DESC appointments;

ALTER TABLE appointments ADD COLUMN pet_type VARCHAR(20);

ALTER TABLE appointments MODIFY COLUMN user_id INT NULL;

ALTER TABLE vet_appointments
MODIFY COLUMN status ENUM('scheduled','cancelled','done') NOT NULL DEFAULT 'scheduled';

ALTER TABLE vet_appointments
MODIFY COLUMN status ENUM('scheduled','cancelled','done') NOT NULL DEFAULT 'scheduled';

UPDATE vet_appointments
SET status = 'done'
WHERE status = 'completed';

SHOW COLUMNS FROM vet_appointments LIKE 'status';


SELECT * FROM consultation_history;

SELECT * FROM users WHERE id = 13;

INSERT INTO users (id, name, email, password, role)
VALUES (13, 'Dr. Riya', 'riya@example.com', '123', 'vet');


INSERT INTO users (name, email, password, role)
VALUES ('Riya Jagtap', 'riya@example.com', 'scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d', 'vet');

INSERT INTO users (name, email, password, role)
VALUES ('Riya Jagtap', 'riya.vet@example.com', 'scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d', 'vet');

SELECT id, name, email FROM users WHERE email='riya@example.com';

SELECT * FROM users;


CREATE TABLE vet_consultations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vet_id INT,
    pet_name VARCHAR(100),
    pet_type VARCHAR(50),
    appointment_time DATETIME,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vet_id) REFERENCES vets(id)
);

SELECT * FROM vet_consultations;     -- Vet dashboard's consultation col
DESC vet_consultations;

ALTER TABLE vet_consultations
ADD COLUMN pet_id INT NOT NULL;

ALTER TABLE vet_consultations
ADD COLUMN owner_id INT NOT NULL;

SELECT * FROM consultation_history;
SELECT * FROM vet_appointments;
SELECT * FROM pet_records;
ALTER TABLE pet_records ADD COLUMN pet_type VARCHAR(50);

CREATE TABLE IF NOT EXISTS pet_health_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    description TEXT,
    document_path VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pet_id) REFERENCES pet_records(id) ON DELETE CASCADE
);


SELECT * FROM stray_reports;
DESC stray_reports;

SELECT * FROM pet_records; -- User dashboard's register pet table
DESC pet_records;

ALTER TABLE pet_records ADD COLUMN gender VARCHAR(10);
ALTER TABLE pet_records
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE pet_records 
ADD COLUMN dob DATE AFTER age,
ADD COLUMN color VARCHAR(50) AFTER dob,
ADD COLUMN vaccination_status VARCHAR(50) AFTER color,
ADD COLUMN photo_path VARCHAR(255) AFTER vaccination_status;

SELECT * FROM pet_health_history;

CREATE TABLE stray_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    ngo_id INT,
    animal_type VARCHAR(50) NOT NULL DEFAULT 'Unknown',
    description TEXT,
    location VARCHAR(100),
    reported_by INT NOT NULL,
    image_path VARCHAR(255),
    report_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','In Progress','Resolved') DEFAULT 'Pending',
    assigned_vet_id INT,

    CONSTRAINT fk_straycases_ngo FOREIGN KEY (ngo_id) REFERENCES ngo(id),
    CONSTRAINT fk_straycases_vet FOREIGN KEY (assigned_vet_id) REFERENCES vets(id),
    CONSTRAINT fk_straycases_user FOREIGN KEY (reported_by) REFERENCES users(id)
);

DESC stray_cases;
SELECT * FROM stray_cases;

SELECT * FROM vets;
SELECT * FROM pet_health_history;


SELECT * FROM vet_appointments;
DESC vet_appointments;

DROP table donations, donors;

SELECT * FROM ngo;
DESC ngo;

SELECT * FROM stray_cases;
DESC stray_cases;
DESC volunteers;

ALTER TABLE pet_records
ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM vets;
DESC vets;

UPDATE vet_appointments
SET vet_id = 13
WHERE vet_id NOT IN (SELECT id FROM vets);

ALTER TABLE vet_appointments
ADD CONSTRAINT vet_appointments_ibfk_2
FOREIGN KEY (vet_id) REFERENCES vets(id);


ALTER TABLE vet_appointments
DROP FOREIGN KEY vet_appointments_ibfk_2;

ALTER TABLE vet_appointments
ADD CONSTRAINT vet_appointments_ibfk_2
FOREIGN KEY (vet_id) REFERENCES vets(id);

SELECT va.vet_id 
FROM vet_appointments va
LEFT JOIN vets v ON va.vet_id = v.id
WHERE v.id IS NULL;

UPDATE vet_appointments
SET vet_id = 1
WHERE vet_id NOT IN (SELECT id FROM vets);

ALTER TABLE vet_appointments
ADD CONSTRAINT vet_appointments_ibfk_2
FOREIGN KEY (vet_id) REFERENCES vets(id);

SELECT *
FROM vet_appointments
WHERE vet_id NOT IN (SELECT id FROM vets);


-- Remove appointments with invalid vet_id
DELETE FROM vet_appointments
WHERE vet_id NOT IN (SELECT id FROM vets);

-- Remove consultations with invalid vet_id
DELETE FROM vet_consultations
WHERE vet_id NOT IN (SELECT id FROM vets);



ALTER TABLE vet_appointments
ADD CONSTRAINT vet_appointments_ibfk_2
FOREIGN KEY (vet_id) REFERENCES vets(id);

ALTER TABLE vet_consultations
ADD CONSTRAINT vet_consultations_ibfk_1
FOREIGN KEY (vet_id) REFERENCES vets(id);

SELECT * FROM vets;

DESC vet_consultations;

SELECT * FROM pet_records;
SELECT * FROM vet_consultations;

SELECT * FROM vet_consultation LIMIT 10;
SELECT * FROM vets LIMIT 10;
SELECT * FROM vet_appointment LIMIT 10;  -- if you have vet_appointment table

CREATE TABLE vet_consultation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vet_id INT NOT NULL,
    pet_name VARCHAR(255) NOT NULL,
    pet_type VARCHAR(100) NOT NULL,
    owner_id INT,
    notes TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vet_id) REFERENCES vets(id)
);

CREATE TABLE vet_appointment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vet_id INT NOT NULL,
    pet_name VARCHAR(255) NOT NULL,
    pet_type VARCHAR(100) NOT NULL,
    appointment_time DATETIME NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'scheduled',
    FOREIGN KEY (vet_id) REFERENCES vets(id)
);

SELECT * FROM vet_consultation;

SELECT * FROM vet_appointments LIMIT 10;

SHOW TABLES LIKE 'vet_consultation';

DESC vet_consultation;

SELECT * FROM users;

SELECT u.name, COUNT(p.id) AS pet_count
FROM users u
LEFT JOIN pet_records p ON u.id = p.owner_id
WHERE u.role = 'pet_owner'
GROUP BY u.id, u.name;

SELECT id, pet_name, pet_type, owner_id FROM pet_records LIMIT 10;

SELECT * FROM pet_records;
DESC pet_records;

SELECT * FROM stray_cases;
DESC stray_cases;



INSERT INTO ngo (id, name, latitude, longitude, location, email, role, password)
VALUES 
(1, 'Happy Paws NGO', 19.0750, 72.8700, 'Chembur, Mumbai', 'contact@happypaws.org', 'ngo', 'test123'),
(2, 'Safe Strays', 19.0820, 72.8350, 'Santacruz, Mumbai', 'contact@safestrays.org', 'ngo', 'test123');


SELECT * FROM users WHERE email = 'contact@happypaws.org';

UPDATE ngo
SET password = 'pbkdf2:sha256:1000000$r0LjyBd1$123df8076b565483a828a209b5ec7cc91b74ed5917a928a4a8fdd5c2f1bc3bd5'
WHERE email = 'contact@happypaws.org';

ALTER TABLE stray_cases
DROP COLUMN assigned_vet_id;


ALTER TABLE stray_cases
ADD COLUMN assigned_volunteer_id INT NULL,
ADD CONSTRAINT fk_assigned_volunteer FOREIGN KEY (assigned_volunteer_id) REFERENCES volunteers(id);


ALTER TABLE stray_cases
ADD COLUMN assigned_volunteer_id INT NULL,
ADD CONSTRAINT fk_assigned_volunteer FOREIGN KEY (assigned_volunteer_id) REFERENCES volunteers(id);

ALTER TABLE stray_cases
DROP FOREIGN KEY fk_straycases_vet;

ALTER TABLE stray_cases
DROP COLUMN assigned_vet_id;

ALTER TABLE stray_cases
MODIFY COLUMN assigned_volunteer_id INT DEFAULT NULL;

ALTER TABLE stray_cases
ADD CONSTRAINT fk_assigned_volunteer FOREIGN KEY (assigned_volunteer_id) REFERENCES volunteers(id);

SHOW CREATE TABLE stray_cases;

UPDATE ngo SET role='ngo' WHERE email='contact@happypaws.org';
UPDATE ngo SET role='ngo' WHERE email='contact@safestrays.org';


UPDATE ngo
SET password = 'pbkdf2:sha256:1000000$r0LjyBd1$123df8076b565483a828a209b5ec7cc91b74ed5917a928a4a8fdd5c2f1bc3bd5'
WHERE email = 'contact@safestrays.org';

-- Update Happy Paws NGO
UPDATE ngo
SET phone = '+919876543210',
    address = 'Chembur, Mumbai, Maharashtra, India',
    location = 'Chembur, Mumbai',
    latitude = 19.075000,
    longitude = 72.870000
WHERE email = 'contact@happypaws.org';

-- Update Safe Strays
UPDATE ngo
SET phone = '+918765432109',
    address = 'Santacruz, Mumbai, Maharashtra, India',
    location = 'Santacruz, Mumbai',
    latitude = 19.082000,
    longitude = 72.835000
WHERE email = 'contact@safestrays.org';

-- Update Bandra Animal Rescue
UPDATE ngo
SET phone = '+917390280068',
    address = 'Bandra Animal Rescue 123, Pali Hill Road, Opposite St. Peter''s Church, Bandra West, Mumbai - 400050 Maharashtra, India',
    location = 'Bandra West, Mumbai',
    latitude = 19.054000,
    longitude = 72.835000
WHERE email = 'bandra.ngo@example.com';

SELECT * FROM ngo;

SELECT id, name, role FROM ngo;

SELECT * FROM vets;
SELECT * FROM users;

ALTER TABLE consultations
ADD COLUMN vet_id INT NOT NULL,
ADD COLUMN owner_id INT NOT NULL;



SELECT * FROM consultation_history;
desc consultation_history;

SELECT * FROM vet_consultation;
DESC vet_consultation;

select * from vet_appointments;

ALTER TABLE vet_consultation
ADD COLUMN pet_id INT;

UPDATE vet_consultation vc
JOIN pet_records pr ON vc.pet_name = pr.pet_name
SET vc.pet_id = pr.id,
    vc.pet_type = pr.pet_type
WHERE vc.pet_id IS NULL
  AND pr.pet_type IS NOT NULL;

SELECT vc.pet_name 
FROM vet_consultation vc
LEFT JOIN pet_records pr ON vc.pet_name = pr.pet_name
WHERE vc.pet_id IS NULL
  AND pr.id IS NULL;

-- Check current pet_records
SELECT id, pet_name, pet_type FROM pet_records;

-- Update vet_consultation to link by pet_name exactly
UPDATE vet_consultation vc
JOIN pet_records pr ON LOWER(TRIM(vc.pet_name)) = LOWER(TRIM(pr.pet_name))
SET vc.pet_id = pr.id,
    vc.pet_type = pr.pet_type
WHERE vc.pet_id IS NULL;

-- Option 1: Update only when pet_type is not null
UPDATE vet_consultation vc
JOIN pet_records pr
  ON LOWER(TRIM(vc.pet_name)) = LOWER(TRIM(pr.pet_name))
SET vc.pet_id = pr.id,
    vc.pet_type = pr.pet_type
WHERE vc.pet_id IS NULL
  AND pr.pet_type IS NOT NULL;
  
  
UPDATE vet_consultation vc
JOIN pet_records pr
  ON LOWER(TRIM(vc.pet_name)) = LOWER(TRIM(pr.pet_name))
SET vc.pet_type = pr.pet_type
WHERE vc.pet_type IS NULL;  
  
UPDATE consultation_history ch
JOIN pet_records pr
  ON LOWER(TRIM(ch.pet_name)) = LOWER(TRIM(pr.pet_name))
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL;


ALTER TABLE consultation_history
ADD COLUMN pet_type VARCHAR(50);

DESCRIBE consultation_history;

UPDATE consultation_history ch
JOIN pet_records pr
  ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL;

UPDATE vet_consultation vc
JOIN pet_records pr ON vc.pet_id = pr.id
SET vc.pet_type = pr.pet_type
WHERE vc.pet_type IS NULL;

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL;

SELECT id, pet_name, pet_type, owner_id, created_at
FROM vet_consultation
WHERE pet_type IS NULL;

SELECT id, pet_id, pet_type, vet_id, created_at
FROM consultation_history
WHERE pet_type IS NULL;

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL;

SELECT id, pet_id, pet_type, vet_id, created_at
FROM consultation_history
WHERE pet_type IS NULL;

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL;

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL OR ch.pet_type = '';


SELECT id, pet_id, pet_type, vet_id, created_at
FROM consultation_history;

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL OR ch.pet_type = '';

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE (ch.pet_type IS NULL OR ch.pet_type = '');

SELECT id, pet_name, pet_type FROM pet_records WHERE id = 1;
UPDATE pet_records
SET pet_type = 'Dog'  -- or the correct type
WHERE id = 1;

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL OR ch.pet_type = '';

SELECT * FROM consultation_history WHERE pet_id = 1;

UPDATE consultation_history ch
JOIN pet_records pr ON ch.pet_id = pr.id
SET ch.pet_type = pr.pet_type
WHERE ch.pet_type IS NULL OR ch.pet_type = '';

UPDATE vet_consultation vc
JOIN pet_records pr ON vc.pet_id = pr.id
SET vc.pet_type = pr.pet_type
WHERE vc.pet_type IS NULL OR vc.pet_type = '';

UPDATE vet_consultation vc
JOIN pet_records pr
  ON LOWER(TRIM(vc.pet_name)) = LOWER(TRIM(pr.pet_name))
SET vc.pet_id = pr.id,
    vc.pet_type = pr.pet_type
WHERE vc.pet_id IS NULL;

SELECT id, pet_name, pet_type, pet_id FROM vet_consultation WHERE pet_type IS NULL;

SELECT id, pet_name, pet_type, pet_id
FROM vet_consultation
WHERE pet_name = 'Bruno';

SELECT id, pet_name, pet_type FROM pet_records WHERE pet_name='Bruno';

UPDATE pet_records
SET pet_type = 'Dog'  -- or the correct type
WHERE pet_name = 'Bruno';

SELECT * FROM pet_records;
ALTER TABLE pet_records
ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

SELECT * FROM ngo;

SELECT * FROM stray_cases;

DELETE FROM stray_cases
WHERE case_id = 9;  -- ID of the duplicate


SELECT case_id, ngo_id, animal_type, description FROM stray_cases;

SELECT * FROM users;

UPDATE stray_cases
SET ngo_id = 2
WHERE case_id IN (8, 9);

SELECT * FROM vet_appointments;
DESC vet_appointments;

INSERT INTO vet_appointments 
(vet_id, pet_name, pet_type, appointment_time, reason, status)
VALUES
(8, 'Bruno', 'Dog', '2025-10-05 10:00:00', 'General Checkup', 'scheduled'),
(9, 'Mittens', 'Cat', '2025-10-05 11:00:00', 'Vaccination', 'scheduled'),
(8, 'Charlie', 'Dog', '2025-10-06 09:30:00', 'Skin Allergy', 'done'),
(10, 'Bella', 'Cat', '2025-10-06 14:00:00', 'Dental Cleaning', 'scheduled'),
(9, 'Max', 'Dog', '2025-10-07 10:30:00', 'Ear Infection', 'cancelled'),
(13, 'Luna', 'Cat', '2025-10-07 15:00:00', 'Vaccination', 'scheduled');

SELECT * FROM stray_cases;
SELECT * FROM stray_reports;

SELECT * FROM users;
DESC users;

UPDATE users
SET name = 'Sahil Shinde'
WHERE id = 12;



desc appointments;
ALTER TABLE appointments ADD COLUMN pet_id INT AFTER vet_id;

ALTER TABLE appointments
ADD CONSTRAINT fk_appointment_pet
FOREIGN KEY (pet_id) REFERENCES pet_records(id)
ON DELETE CASCADE;


SELECT * FROM vets;
SELECT * FROM vet_appointments;
DESC vet_appointments;

SELECT id, pet_name, pet_type, owner_id
FROM pet_records;

ALTER TABLE vet_appointments
ADD COLUMN user_id INT NULL;

UPDATE vet_appointments va
JOIN pet_records p ON va.pet_id = p.id
SET va.user_id = p.owner_id
WHERE va.user_id IS NULL;

UPDATE vet_appointments va
JOIN pet_records p 
  ON va.pet_name = p.pet_name
  AND va.pet_type = p.species
SET va.pet_id = p.id
WHERE va.pet_id IS NULL;

UPDATE vet_appointments va
JOIN pet_records p ON va.pet_id = p.id
SET va.user_id = p.owner_id
WHERE va.user_id IS NULL;

SELECT id, pet_name, pet_type, pet_id, user_id, vet_name, appointment_time, status
FROM vet_appointments
WHERE user_id IS NOT NULL;



SELECT * FROM pet_records;
SELECT * FROM vet_appointments;

-- Bruno (Dog) belongs to Sneha Shah, assume pet_id = 8
UPDATE vet_appointments
SET pet_id = 8
WHERE pet_name = 'Bruno' AND pet_type = 'Dog';

-- Mittens (Cat) belongs to Sanika Patil, assume pet_id = 9
UPDATE vet_appointments
SET pet_id = 9
WHERE pet_name = 'Mittens' AND pet_type = 'Cat';

-- Charlie (Dog) belongs to Sneha Shah, assume pet_id = 8
UPDATE vet_appointments
SET pet_id = 8
WHERE pet_name = 'Charlie' AND pet_type = 'Dog';

-- Bella (Cat) belongs to Soham, assume pet_id = 10
UPDATE vet_appointments
SET pet_id = 10
WHERE pet_name = 'Bella' AND pet_type = 'Cat';

-- Max (Dog) belongs to Sanika Patil, assume pet_id = 9
UPDATE vet_appointments
SET pet_id = 9
WHERE pet_name = 'Max' AND pet_type = 'Dog';

-- Luna (Cat) belongs to Tejal Wagh, assume pet_id = 13
UPDATE vet_appointments
SET pet_id = 13
WHERE pet_name = 'Luna' AND pet_type = 'Cat';

-- Tommy (dog) belongs to Tejal Wagh, assume pet_id = 13
UPDATE vet_appointments
SET pet_id = 13
WHERE pet_name = 'Tommy' AND pet_type = 'dog';

-- Buddy (Dog) belongs to Tejal Wagh, assume pet_id = 13
UPDATE vet_appointments
SET pet_id = 13
WHERE pet_name = 'Buddy' AND pet_type = 'Dog';



ALTER TABLE vet_appointments ADD COLUMN vet_name VARCHAR(100);

UPDATE vet_appointments va
JOIN vets v ON va.vet_id = v.id
SET va.vet_name = v.name
WHERE va.vet_name IS NULL;

UPDATE vet_appointments va
JOIN vets v ON va.vet_id = v.id
SET va.vet_name = v.name
WHERE va.vet_id IS NOT NULL;

DESC users;
SELECT * FROM users;

SELECT * FROM appointments;
DESC appointments;

SELECT id, pet_name, pet_type, user_id FROM vet_appointments WHERE user_id = 1;

SELECT id, vet_id, pet_id, user_id, pet_name, appointment_date, appointment_time, status
FROM appointments
ORDER BY appointment_date DESC;

ALTER TABLE appointments
DROP FOREIGN KEY appointments_ibfk_1;

ALTER TABLE appointments
ADD CONSTRAINT appointments_ibfk_1
FOREIGN KEY (vet_id) REFERENCES vets(id);

INSERT INTO appointments 
    (vet_id, pet_id, user_id, pet_name, appointment_date, appointment_time, reason, status, pet_type)
SELECT 
    vet_id,
    pet_id,
    user_id,
    pet_name,
    DATE(appointment_time) AS appointment_date,
    TIME(appointment_time) AS appointment_time,
    reason,
    CASE 
        WHEN status = 'scheduled' THEN 'Pending'
        WHEN status = 'done' THEN 'Completed'
        WHEN status = 'cancelled' THEN 'Rejected'
        ELSE 'Pending'
    END AS status,
    pet_type
FROM vet_appointments
WHERE user_id IS NOT NULL;

INSERT INTO appointments
(vet_id, pet_id, user_id, pet_name, appointment_date, appointment_time, reason, status, pet_type)
SELECT
    vet_id,
    pet_id,
    user_id,
    pet_name,
    DATE(appointment_time) AS appointment_date,
    TIME(appointment_time) AS appointment_time,
    reason,
    CASE
        WHEN status = 'scheduled' THEN 'Pending'
        WHEN status = 'done' THEN 'Completed'
        WHEN status = 'cancelled' THEN 'Rejected'
        ELSE 'Pending'
    END AS status,
    pet_type
FROM vet_appointments
WHERE user_id IS NOT NULL;

SELECT pet_name, vet_id, appointment_date, appointment_time, reason, COUNT(*) as cnt
FROM appointments
GROUP BY pet_name, vet_id, appointment_date, appointment_time, reason
HAVING cnt > 1;

DELETE a1
FROM appointments a1
JOIN appointments a2 
  ON a1.pet_name = a2.pet_name
 AND a1.vet_id = a2.vet_id
 AND a1.appointment_date = a2.appointment_date
 AND a1.appointment_time = a2.appointment_time
 AND a1.reason = a2.reason
 AND a1.id > a2.id;

SELECT id, user_id, pet_name, appointment_date FROM appointments;

-- Ensure vet_id is NOT NULL
ALTER TABLE appointments
MODIFY COLUMN vet_id INT NOT NULL;

ALTER TABLE appointments ADD COLUMN user_id INT AFTER vet_id;
ALTER TABLE appointments ADD COLUMN pet_id INT AFTER user_id;
ALTER TABLE appointments ADD COLUMN pet_name VARCHAR(100) AFTER pet_id;
ALTER TABLE appointments ADD COLUMN pet_type VARCHAR(20) AFTER pet_name;
ALTER TABLE appointments ADD COLUMN appointment_date DATE AFTER pet_type;
ALTER TABLE appointments ADD COLUMN appointment_time TIME AFTER appointment_date;
ALTER TABLE appointments ADD COLUMN reason TEXT AFTER appointment_time;
ALTER TABLE appointments ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;


-- Update the status enum to match the model
ALTER TABLE appointments
MODIFY COLUMN status ENUM('Pending','Approved','Rejected','Completed') DEFAULT 'Pending';

UPDATE appointments
SET status = 'Completed'
WHERE id = 4;

SELECT *
FROM vet_appointments
WHERE pet_id IN (36, 42, 44, 45, 46, 47)
ORDER BY appointment_time;

SELECT id, pet_name, pet_id
FROM vet_appointments
LIMIT 10;

SELECT *
FROM vet_appointments
WHERE pet_id IN (1, 2)
ORDER BY appointment_time;

UPDATE consultations
SET pet_type = 'Cat',       
    notes = 'Updated notes' 
WHERE id = 2;               



DESC appointments;

DESC vet_appointments;

SELECT * FROM appointments;

SELECT * FROM vet_appointments;

SELECT va.*
FROM vet_appointments va
JOIN user_appointments ua
  ON va.pet_id = ua.pet_id
  AND va.date = ua.date
  AND va.slot = ua.slot
WHERE ua.user_name = 'Riya Jagtap'
ORDER BY va.date, va.slot;

SELECT id 
FROM pets 
WHERE owner_name = 'Riya Jagtap';

SELECT *
FROM vet_appointments
WHERE user_name = 'Riya Jagtap'
ORDER BY date, slot;

SELECT id, pet_name
FROM vet_appointments
WHERE pet_name IN ('Bruno', 'Tommy');

SELECT *
FROM vet_appointments
WHERE pet_id IN (36, 42, 44, 45, 46, 47)
ORDER BY date_time;

UPDATE consultation_history
SET pet_type = 'Cat',
    notes = 'Apply special ointment'
WHERE pet_name = 'CHINU';

DESC vet_consultation;
SELECT * FROM vet_consultation;
DESC consultation_history;

DELETE FROM vet_consultation
WHERE owner_id IS NULL;

SELECT * FROM vet_consultation;

SELECT *
FROM vet_appointments
WHERE status != 'cancelled'
AND (source = 'Owner' OR (source = 'Vet' AND status != 'completed'))
ORDER BY appointment_time DESC
LIMIT 0, 100;

SELECT *
FROM vet_appointments
WHERE status != 'cancelled'
GROUP BY pet_id, appointment_time
ORDER BY appointment_time DESC
LIMIT 0, 100;

WITH ranked_appointments AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY pet_id, appointment_time ORDER BY id DESC) AS rn
    FROM vet_appointments
    WHERE status != 'cancelled'
)
SELECT *
FROM ranked_appointments
WHERE rn = 1
ORDER BY appointment_time DESC
LIMIT 0, 100;

WITH ranked AS (
    SELECT 
        id,
        pet_name,
        pet_type,
        appointment_time,
        status,
        source,
        ROW_NUMBER() OVER (PARTITION BY pet_name, appointment_time ORDER BY id DESC) AS rn
    FROM vet_appointments
)
SELECT * FROM ranked WHERE rn > 1;

WITH ranked AS (
    SELECT 
        id,
        pet_name,
        pet_type,
        appointment_time,
        status,
        ROW_NUMBER() OVER (PARTITION BY pet_name, appointment_time ORDER BY id DESC) AS rn
    FROM vet_appointments
)
SELECT * FROM ranked WHERE rn > 1;

WITH ranked AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY pet_name, appointment_time ORDER BY id DESC) AS rn
    FROM vet_appointments
)
DELETE FROM vet_appointments
WHERE id IN (SELECT id FROM ranked WHERE rn > 1);

SELECT *
FROM vet_appointments
ORDER BY appointment_time DESC
LIMIT 100;

SELECT 
    id,
    pet_name,
    UPPER(LEFT(pet_type,1)) || LOWER(SUBSTRING(pet_type,2)) AS pet_type,
    appointment_time,
    status,
    vet_name
FROM vet_appointments
ORDER BY appointment_time DESC
LIMIT 100;


UPDATE vet_consultation
SET pet_type = 'Cat',
    notes = 'Updated notes for CHINU'
WHERE pet_name = 'CHINU';

UPDATE consultation_history ch
JOIN vet_consultation vc
  ON ch.pet_id = vc.pet_id AND ch.vet_id = vc.vet_id
SET ch.pet_type = vc.pet_type,
    ch.notes = vc.notes
WHERE vc.pet_name = 'CHINU';

SELECT vc.pet_name,
       vc.pet_type,
       u.name AS owner_name,
       vc.notes,
       vc.status,
       vc.created_at
FROM vet_consultation vc
LEFT JOIN users u ON vc.owner_id = u.id
ORDER BY vc.created_at DESC;

SELECT id, pet_name, owner_id
FROM vet_consultation
WHERE owner_id IS NULL OR owner_id NOT IN (SELECT id FROM users);

SELECT vc.pet_name,
       vc.pet_type,
       u.name AS owner_name,
       vc.notes,
       vc.status,
       vc.created_at
FROM vet_consultation vc
LEFT JOIN users u ON vc.owner_id = u.id
ORDER BY vc.created_at DESC;

UPDATE vet_consultation
SET owner_id = NULL
WHERE pet_name IN ('CHINU', 'luna');




DESCRIBE users;


SELECT * FROM pet_records;

SELECT * FROM ngo;

SELECT * FROM stray_cases;

UPDATE stray_cases
SET image_path = REPLACE(REPLACE(image_path, 'static/', ''), '\\', '/')
WHERE image_path IS NOT NULL;

DESC stray_reports;

SELECT * FROM stray_cases WHERE ngo_id = 2;

SELECT * FROM contact_messages;
DESC contact_messages;

DELETE FROM contact_messages where full_name = 'Sahil Shinde';

SELECT * FROM feedback;
DELETE FROM feedback where user_id = 1;
DELETE FROM feedback where name = "Riya Suresh Jagtap";
DESC feedback;

DESC users;
SELECT * FROM users;

DESC ngo;
SELECT * FROM ngo;

SELECT * FROM appointments;

SELECT id, name, email FROM users WHERE id = 1;

UPDATE users
SET name = 'Shanaya Ghag'
WHERE email = 'shanaya@example.com';


SELECT * FROM stray_cases;
SELECT * FROM stray_reports;
SHOW DATABASES;

SHOW TABLES;
