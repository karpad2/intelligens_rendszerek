-- phpMyAdmin SQL Dump
-- version 5.0.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 20, 2020 at 07:45 PM
-- Server version: 10.4.14-MariaDB
-- PHP Version: 7.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `idomero`
--
CREATE DATABASE IF NOT EXISTS `idomero` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `idomero`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `auth_times_pre`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `auth_times_pre` (IN `RFID` VARCHAR(50))  begin
       declare c enum('login','logout');
       select Active into c from peoples where peoples.RFID=RFID;
      -- select c;
       if isnull(c) then
        insert into peoples values (RFID,'Temporary Joe',1);
       end if;

       if c='login' then
           -- select 'login';
            insert into auth_times values (RFID,NOW(),'logout');
            update peoples  set Active='logout' where peoples.RFID=RFID;
        else
           -- select 'logout';
           insert into auth_times values (RFID,NOW(),'login');
           update peoples  set Active='login' where peoples.RFID=RFID;
        end if;

    end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `auth_times`
--

DROP TABLE IF EXISTS `auth_times`;
CREATE TABLE `auth_times` (
  `RFID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Date` timestamp NOT NULL DEFAULT current_timestamp(),
  `login` enum('login','logout') COLLATE utf8mb4_unicode_ci DEFAULT 'login'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `auth_times`
--

TRUNCATE TABLE `auth_times`;
--
-- Dumping data for table `auth_times`
--

INSERT IGNORE INTO `auth_times` (`RFID`, `Date`, `login`) VALUES
('8327bf1a', '2020-11-19 11:17:09', 'login'),
('8327bf1a', '2020-11-19 11:17:26', 'logout'),
('8327bf1a', '2020-11-19 11:18:18', 'login'),
('8327bf1a', '2020-11-19 11:18:20', 'logout'),
('8327bf1a', '2020-11-19 11:24:35', 'login'),
('8327bf1a', '2020-11-19 11:24:39', 'logout'),
('96a6f4f9', '2020-11-19 11:17:01', 'logout'),
('a2a48233', '2020-11-17 19:25:33', 'login'),
('add6bded', '2020-11-17 17:57:24', 'login'),
('add6bded', '2020-11-17 17:58:48', 'logout'),
('add6bded', '2020-11-17 19:25:06', 'login'),
('add6bded', '2020-11-19 11:16:20', 'logout'),
('add6bded', '2020-11-19 11:16:30', 'login'),
('add6bded', '2020-11-19 11:16:46', 'logout'),
('add6bded', '2020-11-19 11:16:48', 'login'),
('add6bded', '2020-11-19 11:16:54', 'logout'),
('add6bded', '2020-11-19 11:17:56', 'login'),
('add6bded', '2020-11-19 11:17:59', 'logout'),
('add6bded', '2020-11-19 11:18:04', 'login'),
('add6bded', '2020-11-19 11:18:06', 'logout'),
('add6bded', '2020-11-19 11:24:45', 'login'),
('add6bded', '2020-11-19 11:24:55', 'logout');

-- --------------------------------------------------------

--
-- Table structure for table `peoples`
--

DROP TABLE IF EXISTS `peoples`;
CREATE TABLE `peoples` (
  `RFID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Active` enum('login','logout') COLLATE utf8mb4_unicode_ci DEFAULT 'login'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `peoples`
--

TRUNCATE TABLE `peoples`;
--
-- Dumping data for table `peoples`
--

INSERT IGNORE INTO `peoples` (`RFID`, `Name`, `Active`) VALUES
('8327bf1a', 'Temporary Joe', 'logout'),
('96a6f4f9', 'Kovács Emese', 'logout'),
('a2a48233', 'Kovács Ferenc', 'login'),
('add6bded', 'Kovacs Arpad', 'logout'),
('asdasd', 'TadesDead', 'login');

-- --------------------------------------------------------

--
-- Stand-in structure for view `workers_hour`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `workers_hour`;
CREATE TABLE `workers_hour` (
`RFID` varchar(50)
,`Name` varchar(50)
,`Date` timestamp
,`Worked Time` time
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `workers_hour_by_date`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `workers_hour_by_date`;
CREATE TABLE `workers_hour_by_date` (
`Name` varchar(50)
,`Time` time
,`Date` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `workers_hour_by_day`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `workers_hour_by_day`;
CREATE TABLE `workers_hour_by_day` (
`Name` varchar(50)
,`Time` time
,`Date` timestamp
);

-- --------------------------------------------------------

--
-- Structure for view `workers_hour`
--
DROP TABLE IF EXISTS `workers_hour`;

DROP VIEW IF EXISTS `workers_hour`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `workers_hour`  AS SELECT `a`.`RFID` AS `RFID`, `p`.`Name` AS `Name`, `a`.`Date` AS `Date`, timediff(`b`.`Date`,`a`.`Date`) AS `Worked Time` FROM ((select `aub`.`RFID` AS `RFID`,`aub`.`Date` AS `Date`,`aub`.`login` AS `login` from `auth_times` `aub` order by `aub`.`Date`) `b` left join (`auth_times` `a` join `peoples` `p` on(`a`.`RFID` = `p`.`RFID`)) on(`a`.`RFID` = `b`.`RFID`)) WHERE `a`.`Date` < `b`.`Date` AND dayofmonth(`b`.`Date`) = dayofmonth(`a`.`Date`) AND `a`.`login` = 'login' ;

-- --------------------------------------------------------

--
-- Structure for view `workers_hour_by_date`
--
DROP TABLE IF EXISTS `workers_hour_by_date`;

DROP VIEW IF EXISTS `workers_hour_by_date`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `workers_hour_by_date`  AS SELECT `tmp`.`Name` AS `Name`, `tmp`.`Time` AS `Time`, `tmp`.`Date` AS `Date` FROM (select `workers_hour`.`Name` AS `Name`,sec_to_time(sum(time_to_sec(`workers_hour`.`Worked Time`))) AS `Time`,`workers_hour`.`Date` AS `Date` from `workers_hour` group by dayofmonth(`workers_hour`.`Date`)) AS `tmp` GROUP BY `tmp`.`Name` ;

-- --------------------------------------------------------

--
-- Structure for view `workers_hour_by_day`
--
DROP TABLE IF EXISTS `workers_hour_by_day`;

DROP VIEW IF EXISTS `workers_hour_by_day`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `workers_hour_by_day`  AS SELECT `workers_hour`.`Name` AS `Name`, sec_to_time(sum(time_to_sec(`workers_hour`.`Worked Time`))) AS `Time`, `workers_hour`.`Date` AS `Date` FROM `workers_hour` GROUP BY `workers_hour`.`Name` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `auth_times`
--
ALTER TABLE `auth_times`
  ADD PRIMARY KEY (`RFID`,`Date`);

--
-- Indexes for table `peoples`
--
ALTER TABLE `peoples`
  ADD PRIMARY KEY (`RFID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `auth_times`
--
ALTER TABLE `auth_times`
  ADD CONSTRAINT `auth_times_ibfk_1` FOREIGN KEY (`RFID`) REFERENCES `peoples` (`RFID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
