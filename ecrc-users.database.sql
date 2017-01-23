--
-- Table structure for table `active_users`
--

DROP TABLE IF EXISTS `active_users`;
CREATE TABLE `active_users` (
  `user` char(16) NOT NULL DEFAULT '',
  `server` char(16) NOT NULL DEFAULT '',
  `last` date DEFAULT NULL,
  PRIMARY KEY (`user`,`server`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `servers`
--

DROP TABLE IF EXISTS `servers`;
CREATE TABLE `servers` (
  `name` char(16) NOT NULL,
  `ip` char(16) DEFAULT NULL,
  `ncores` int(11) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `username` char(16) NOT NULL,
  `uid` int(11) DEFAULT NULL,
  `name` char(64) DEFAULT NULL,
  `email` char(64) DEFAULT NULL,
  `comment` char(64) DEFAULT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
