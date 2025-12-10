-- Creates player_jobs table to store multiple jobs per player
CREATE TABLE `player_jobs` (
    `citizenid` varchar(100) NOT NULL,
    `job` varchar(100) NOT NULL,
    `grade` int(11) NOT NULL
);