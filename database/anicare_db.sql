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

-- Dump completed on 2025-09-19 12:30:15
