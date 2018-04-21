-- MySQL dump 10.13  Distrib 5.7.21, for Linux (x86_64)
--
-- Host: localhost    Database: media
-- ------------------------------------------------------
-- Server version	5.7.21-0ubuntu0.16.04.1
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category` (
  `id` int(11) unsigned NOT NULL,
  `name` varchar(256) NOT NULL,
  `asset_type` varchar(128) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (1,'dark classical','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (2,'funk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (3,'mash-ups','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (4,'rap','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (5,'acid jazz','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (6,'afro-beat','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (7,'ambi-sonic','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (8,'ambient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (9,'ambient noise','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (10,'ambient soundscapes','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (11,'art punk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (12,'art rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (13,'avant-garde','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (14,'black metal','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (15,'blues','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (16,'chamber goth','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (17,'classic rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (18,'classical','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (19,'classics','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (20,'contemporary classical','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (21,'country','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (22,'dark ambient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (23,'deathrock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (24,'deep ambient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (25,'disco','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (26,'doom jazz','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (27,'drum & bass','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (28,'dubstep','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (29,'electroclash','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (30,'electronic','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (31,'electronic [abstract hip-hop, illbient]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (32,'electronic [ambient groove]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (33,'electronic [armchair techno, emo-glitch]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (34,'electronic [minimal]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (35,'ethnoambient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (36,'experimental','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (37,'folk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (38,'folk-horror','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (39,'garage rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (40,'goth metal','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (41,'gothic','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (42,'grime','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (43,'gun rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (44,'hardcore','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (45,'hip-hop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (46,'hip-hop (old school)','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (47,'hip-hop [chopped & screwed]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (48,'house','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (49,'idm','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (50,'incidental','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (51,'indie','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (52,'industrial','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (53,'industrial rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (54,'industrial [soundscapes]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (55,'jazz','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (56,'krautrock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (57,'martial ambient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (58,'martial folk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (59,'martial industrial','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (60,'modern rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (61,'neo-folk, neo-classical','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (62,'new age','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (63,'new soul','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (64,'new wave, synthpop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (65,'noise, powernoise','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (66,'oldies','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (67,'pop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (68,'post-pop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (69,'post-rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (70,'powernoise','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (71,'psychedelic rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (72,'punk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (73,'punk [american]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (74,'rap (chopped & screwed)','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (75,'rap (old school)','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (76,'reggae','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (77,'ritual ambient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (78,'ritual industrial','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (79,'rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (80,'roots rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (81,'russian hip-hop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (82,'ska','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (83,'soul','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (84,'soundtracks','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (85,'surf rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (86,'synthpunk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (87,'trip-hop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (88,'urban','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (89,'visual kei','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (90,'world fusion','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (91,'world musics','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (92,'alternative','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (93,'atmospheric','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (94,'new wave','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (95,'noise','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (96,'synthpop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (97,'unsorted','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (98,'coldwave','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (99,'film music','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (100,'garage punk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (101,'goth','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (102,'mash-up','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (103,'minimal techno','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (104,'mixed','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (105,'nu jazz','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (106,'post-punk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (107,'psytrance','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (108,'ragga soca','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (109,'reggaeton','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (110,'ritual','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (111,'rockabilly','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (112,'smooth jazz','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (113,'techno','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (114,'tributes','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (115,'various','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (116,'celebrational','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (117,'classic ambient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (118,'electronic rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (119,'electrosoul','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (120,'fusion','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (121,'glitch','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (122,'go-go','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (123,'hellbilly','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (124,'illbient','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (125,'industrial [rare]','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (126,'jpop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (127,'mashup','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (128,'minimal','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (129,'modern soul','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (130,'neo soul','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (131,'neo-folk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (132,'new beat','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (133,'satire','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (134,'dark jazz','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (135,'classic hip-hop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (136,'electronic dance','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (137,'minimal house','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (138,'minimal wave','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (139,'afrobeat','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (140,'heavy metal','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (141,'new wave, goth, synthpop, alternative','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (142,'ska, reggae','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (143,'soul & funk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (144,'psychedelia','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (145,'americana','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (146,'dance','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (147,'glam','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (148,'gothic & new wave','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (149,'punk & new wave','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (150,'random','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (151,'rock, metal, pop','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (152,'sound track','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (153,'soundtrack','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (154,'spacerock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (155,'tribute','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (156,'unclassifiable','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (157,'unknown','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (158,'weird','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (159,'darkwave','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (160,'experimental-noise','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (161,'general alternative','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (162,'girl group','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (163,'gospel & religious','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (164,'alternative & punk','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (165,'bass','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (166,'beat','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (167,'black rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (168,'classic','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (169,'japanese','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (170,'kanine','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (171,'metal','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (172,'moderne','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (173,'noise rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (174,'other','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (175,'post-punk & minimal wave','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (176,'progressive rock','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (177,'psychic tv','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (178,'punk & oi','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (179,'radio','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (180,'rock\'n\'soul','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (181,'spoken word','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (182,'temp','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (183,'trance','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (184,'vocal','directory');
INSERT INTO `category` (`id`, `name`, `asset_type`) VALUES (185,'world','directory');
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
