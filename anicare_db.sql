-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: anicare_db
-- ------------------------------------------------------
-- Server version	8.0.44

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
  `pet_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `pet_name` varchar(100) DEFAULT NULL,
  `appointment_date` date DEFAULT NULL,
  `appointment_time` time DEFAULT NULL,
  `reason` text,
  `status` enum('Pending','Approved','Rejected','Completed','Cancelled') DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `pet_type` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `vet_id` (`vet_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_appointment_pet` (`pet_id`),
  CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`vet_id`) REFERENCES `vets` (`id`),
  CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_appointment_pet` FOREIGN KEY (`pet_id`) REFERENCES `pet_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (4,8,2,1,'Bruno','2025-10-05','10:00:00','General Checkup','Completed','2025-10-12 14:36:57','Dog'),(5,13,1,1,'Tommy','2025-10-04','11:00:00','Red patches on the skin','Cancelled','2025-10-12 14:36:57','dog'),(6,8,2,1,'Bruno','2025-10-12','15:00:00','Routine annual wellness exam and necessary vaccinations.','Pending','2025-10-12 14:36:57','Dog'),(7,9,2,1,'Bruno','2025-10-12','09:30:00','annual health check up','Pending','2025-10-12 14:36:57','Dog'),(8,13,2,1,'Bruno','2025-10-13','15:00:00','annual health checkup','Completed','2025-10-12 14:36:57','Dog'),(9,13,1,1,'Tommy','2025-10-13','15:30:00','Routine screenings for blood pressure, cholesterol, sugar, etc.','Completed','2025-10-12 14:36:57','Dog'),(18,8,1,1,'Tommy','2025-11-08','12:30:00','vomiting','Pending','2025-11-04 12:27:00','Dog');
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
  `pet_type` varchar(50) DEFAULT NULL,
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
INSERT INTO `consultation_history` VALUES (2,8,1,'Fever and weakness','Antibiotics prescribed','2025-09-02','Follow-up in 5 days','2025-09-01 20:34:20','Dog');
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
INSERT INTO `contact_messages` VALUES (1,'vet','Riya Test','riya@example.com','Test Subject','Testing contact page','2025-09-18 18:40:29'),(2,'ngo','Ruchi Suresh Jagtap','ruchijagtap.2023@gmail.com','collaboration','Request about collaboration with my PetPal NGO','2025-09-18 18:57:46'),(3,'user','Soham Suresh Jagtap','soham@example.com','collaboration','Wanted to enquire about the volunteer start date &  timings','2025-09-18 19:03:51'),(4,'vet','Aditi Suresh Jagtap','aditi@example.com','collaboration','Starting a new vet clinic at Bandra, thinking of collaborating with your organization','2025-09-18 19:17:55'),(6,'user','Riya Suresh Jagtap','riyajagtap.2023@gmail.com','general','hello world...','2025-09-19 05:47:45'),(22,'user','Riya Jagtap','riya@example.com','general','Hi AniCare Team,\r\nI came across your platform and really liked the concept! I wanted to know more about how the vet appointment feature works and if there are any upcoming updates planned for pet owners.','2025-10-16 08:43:03');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` VALUES (3,NULL,'The vet consultation was excellent and very thorough. I felt my dog Bruno and tommy was well taken care of.','2025-10-16 16:24:45','Riya Jagtap','riya@example.com');
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ngo`
--

LOCK TABLES `ngo` WRITE;
/*!40000 ALTER TABLE `ngo` DISABLE KEYS */;
INSERT INTO `ngo` VALUES (1,'Happy Paws NGO','ngo','contact@happypaws.org','pbkdf2:sha256:1000000$r0LjyBd1$123df8076b565483a828a209b5ec7cc91b74ed5917a928a4a8fdd5c2f1bc3bd5','+919876543210','Chembur, Mumbai, Maharashtra, India','Chembur, Mumbai','2025-10-01 04:06:22',19.075000,72.87),(2,'Safe Strays','ngo','contact@safestrays.org','pbkdf2:sha256:1000000$r0LjyBd1$123df8076b565483a828a209b5ec7cc91b74ed5917a928a4a8fdd5c2f1bc3bd5','+918765432109','Santacruz, Mumbai, Maharashtra, India','Santacruz, Mumbai','2025-10-01 04:06:26',19.082000,72.835),(17,'Bandra Animal Rescue','ngo','bandra.ngo@example.com','pbkdf2:sha256:1000000$0W6pAZWj$946c575abd2d6c9bdc5f683d7b366efa3cf537b5b089be5d9f3541d19962b588','+917390280068','Bandra Animal Rescue 123, Pali Hill Road, Opposite St. Peter\'s Church, Bandra West, Mumbai - 400050 Maharashtra, India','Bandra West, Mumbai','2025-11-05 09:32:48',19.054000,72.835),(18,'StrayCare India','ngo','straycare@example.com','pbkdf2:sha256:1000000$cM1U9GzW$df9da77113aac3a0e796f37b58c6083c974153b41bb724cd5024150a93201fb1','','StrayCare India, 47 Andheri West, Mumbai, Maharashtra, India','Andheri West, Mumbai','2025-10-17 09:21:31',19.070000,72.84);
/*!40000 ALTER TABLE `ngo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pet_health_history`
--

DROP TABLE IF EXISTS `pet_health_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet_health_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pet_id` int NOT NULL,
  `event_date` date NOT NULL,
  `event_type` varchar(255) NOT NULL,
  `description` text,
  `document_path` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `pet_id` (`pet_id`),
  CONSTRAINT `pet_health_history_ibfk_1` FOREIGN KEY (`pet_id`) REFERENCES `pet_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pet_health_history`
--

LOCK TABLES `pet_health_history` WRITE;
/*!40000 ALTER TABLE `pet_health_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `pet_health_history` ENABLE KEYS */;
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
  `dob` date DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `vaccination_status` varchar(50) DEFAULT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `medical_history` text,
  `vet_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pet_type` varchar(50) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `pet_records_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pet_records`
--

LOCK TABLES `pet_records` WRITE;
/*!40000 ALTER TABLE `pet_records` DISABLE KEYS */;
INSERT INTO `pet_records` VALUES (1,1,'Tommy','Dog','Labrador',3,'2022-07-07','Golden white','Up-to-date','uploads/pet_1_20251013073949_tommy.webp','none',NULL,'2025-09-30 11:08:32','Dog','Male','2025-10-13 07:39:49'),(2,1,'Bruno','Dog','Indie',2,'2023-02-01','Brown','Up-to-date','uploads/pet_1_20251001000823_dog.png','none',NULL,'2025-09-30 18:38:23','Dog','Male','2025-10-02 00:17:31'),(3,12,'Thumper','Rabbit','Holland Lop',2,'2023-05-12','white','Up-to-date','uploads/pet_12_20251003035239_white-holland-lop-walking.webp','none',NULL,'2025-10-02 22:22:39',NULL,'Male','2025-10-03 03:52:39');
/*!40000 ALTER TABLE `pet_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stray_cases`
--

DROP TABLE IF EXISTS `stray_cases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stray_cases` (
  `case_id` int NOT NULL AUTO_INCREMENT,
  `ngo_id` int DEFAULT NULL,
  `animal_type` varchar(50) NOT NULL DEFAULT 'Unknown',
  `description` text,
  `location` varchar(100) DEFAULT NULL,
  `reported_by` int NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `report_datetime` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Pending','In Progress','Resolved') DEFAULT 'Pending',
  `assigned_volunteer_id` int DEFAULT NULL,
  PRIMARY KEY (`case_id`),
  KEY `fk_straycases_ngo` (`ngo_id`),
  KEY `fk_straycases_user` (`reported_by`),
  KEY `fk_assigned_volunteer` (`assigned_volunteer_id`),
  CONSTRAINT `fk_assigned_volunteer` FOREIGN KEY (`assigned_volunteer_id`) REFERENCES `volunteers` (`id`),
  CONSTRAINT `fk_straycases_ngo` FOREIGN KEY (`ngo_id`) REFERENCES `ngo` (`id`),
  CONSTRAINT `fk_straycases_user` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stray_cases`
--

LOCK TABLES `stray_cases` WRITE;
/*!40000 ALTER TABLE `stray_cases` DISABLE KEYS */;
INSERT INTO `stray_cases` VALUES (8,2,'dog','limping dog','Mumbai',1,'uploads/unwell_dog.jpg','2025-10-01 03:13:39','Resolved',NULL),(10,2,'cat','Small black cat, appears lost and hungry','Mumbai',12,'lost_black_cat.jpg','2025-10-03 14:12:10','Pending',NULL),(11,1,'dog','Injured front leg, seems weak','Mumbai',1,'injured_dog.jpg','2025-10-16 21:16:20','Pending',NULL),(12,17,'other','Parrot sitting on the pavement, wing seems broken','Mumbai',12,'injured_parrot.jpg','2025-10-16 23:40:24','Pending',NULL),(13,18,'dog','A medium-sized brown stray dog with a small injury on its left leg, currently roaming near the park./','Mumbai',14,'brown_injured_dog.jpg','2025-10-17 09:22:10','Pending',NULL);
/*!40000 ALTER TABLE `stray_cases` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Riya Jagtap','riya@example.com','pbkdf2:sha256:1000000$bXm61YIq$76263375ccb2550f8f04c688efbd78322d1b00e0b2fa2d20e32b0831a8cd806f','pet_owner',NULL),(2,'Dr. Mehta','vet@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','vet',NULL),(4,'Riya','riya@user.com','scrypt:32768:8:1$WqW17mVhHfns5Guw$9baa86c84d16f01e1b2d3b586e4b92f737fb562db4b6fe10511b38d6d0912165ae885ec9fdd6cfd7f3fea5c3c951b4599c98eeb36a6062eb0696a76a20c965ce','pet_owner',NULL),(5,'Soham','user@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(6,'Sanika','sanika@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','pet_owner',NULL),(7,'Gauri','gauri@example.com','scrypt:32768:8:1$jr6DD8imB29BJDFt$91a89d08eb5d1f6b7af8df2d564bfdf5cc52d93cbd93630199927bc48a93b5552d735b7a4d0aaa43b18b7151864f12a2f66d2d77572d753a8e5d4da66e86d93d','vet',NULL),(8,'Tester','tester@example.com','scrypt:32768:8:1$MyvjdyDU$4efa0e38a905129e90c5b933533fb5bd67ead8c711538a715d83a2bac40ac0e5430121f1e97823c7aa71da44aec7ce3bff64004438a466ddd1bfea448984b6ed','pet_owner',NULL),(9,'NGO Test','ngo@example.com','scrypt:32768:8:1$VOW4A9MX$846162d95bb59ea7df13f097f9c6e5b301caf3a9cff2196f1d3688e50fc8a7d75c841d35191094ce9cf96c4b173d62b6b62952e9f4df19bcb297993d60128049','ngo',NULL),(10,'Paws & Claws Trust','pawstrust@example.com','scrypt:32768:8:1$ZfifO1S0$9d5a7a944e5338efee0137f163997224e372e0ab9f88de21ff3a9d5d4b0b646247b497ba91bf5b3f22a6d4f56445aad9cf3379b21ee77678a87f326a1bd297a8','ngo',NULL),(12,'Sahil Shinde','sahil@example.com','pbkdf2:sha256:1000000$5aXijQIF$a4f1f41ca5d063ffeca47288bddb541f46e7fd9f03a74573ebccdba8162cd606','pet_owner',''),(14,'Shanaya Ghag','shanaya@example.com','pbkdf2:sha256:1000000$zIMeb1Ie$b90917cf3f7960360c8c48562c06be4bf6a699c93ba43a409572a206ddbd9a90','pet_owner','');
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

--
-- Table structure for table `vet_consultation`
--

DROP TABLE IF EXISTS `vet_consultation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vet_consultation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vet_id` int NOT NULL,
  `pet_name` varchar(255) NOT NULL,
  `pet_type` varchar(100) NOT NULL,
  `owner_id` int DEFAULT NULL,
  `notes` text NOT NULL,
  `status` varchar(50) DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `pet_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `vet_id` (`vet_id`),
  CONSTRAINT `vet_consultation_ibfk_1` FOREIGN KEY (`vet_id`) REFERENCES `vets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vet_consultation`
--

LOCK TABLES `vet_consultation` WRITE;
/*!40000 ALTER TABLE `vet_consultation` DISABLE KEYS */;
INSERT INTO `vet_consultation` VALUES (3,13,'Tommy','Dog',1,'give healskin ointmneet','completed','2025-10-01 20:56:22',1),(4,9,'Thumper','-',12,'Administered DHPP vaccine. Pet tolerated well. Next vaccination due in one year.','completed','2025-10-17 00:51:03',3);
/*!40000 ALTER TABLE `vet_consultation` ENABLE KEYS */;
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
INSERT INTO `vets` VALUES (8,'Sneha Shah','priya@example.com','+917390280068','cardiology','2025-09-01 11:54:48','2025-09-02 15:41:01','scrypt:32768:8:1$PFd6DSCZD17yzJrC$f2de2137bde2ed10cb727f209847d8d936b8cd441b2d2e3d5b9d60bf9368d39c328be0a5fc71e7b46a04dfad78efd0f1f16bbb64e9f3c9264225ac3b2c1126aa','123, Pet care lane, Mumbai','Dr. Sneha Shah, DVM – Veterinary Cardiologist\r\nDr. Sneha Shah is a board-certified veterinary cardiologist specializing in diagnosing and treating heart and circulatory disorders in pets. She uses advanced tools like echocardiography and ECG to provide personalized care, ensuring pets lead healthier, happier lives.',NULL,NULL,'10:00:00','18:00:00'),(9,'Sanika Patil','sanika@example.com','+917941858137','dermatology','2025-09-02 18:52:25','2025-09-02 18:57:37','scrypt:32768:8:1$HjEgSqMc$e4b16b106ce57ec04df42ee32d6f56f95574dc6fce59eba478d5dbb2c44fc6b3bcc42c007bb53c715a955d841972ff3cec981f191bf32cec1d84450aa22398e0','F, Guruprasad Divine Residency, 1B, Pt CR Vyas Marg, near Chembur, Swastik Park, Chembur, Mumbai, Maharashtra 400071','Dr. Sanika is a dedicated veterinary professional specializing in dermatology. She focuses on diagnosing and treating skin disorders, allergies, and coat-related conditions in pets, ensuring their comfort and overall well-being.',NULL,NULL,'10:00:00','18:00:00'),(10,'Soham','soham@example.com','','','2025-09-02 19:29:29','2025-09-02 19:29:29','scrypt:32768:8:1$HTzyHBj0$fccb4dd5ddb6630cf5f56fc49517e18f78e2538f6a252a432d756366f4cb6ef0589cc4f46add65953a68ba757e4dd27c5a91c5788f93e212a981451c6e2bb59b','',NULL,NULL,NULL,'10:00:00','18:00:00'),(13,'Tejal Wagh','tejal@example.com','8433901697','Dermatology','2025-09-15 19:02:31','2025-11-05 09:22:44','pbkdf2:sha256:1000000$KKFiwajk$75100746cfe311dc6b19a133f7be57c706c1bbe6c93828b7cdec00b65154c483','2A/305, Pragati Mandal C.H.S, near Gupta stores, Golibar road, Santacruz East, Mumbai -55','Experienced veterinarian specializing in dermatology with a passion for keeping pets healthy and happy.',NULL,NULL,'10:00:00','18:00:00');
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

-- Dump completed on 2025-11-05 17:44:08
