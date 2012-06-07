-- ---------------------------------- --
-- service_manager.sql                --
-- Base de donnees du Service Manager --
-- Auteur: Koener Herve               --
-- ---------------------------------- -- 

--
-- Structure de la table `action`
--

CREATE TABLE IF NOT EXISTS `action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` int(11) NOT NULL,
  `kind` int(11) DEFAULT NULL,
  `mixin` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category` (`category`),
  KEY `kind` (`kind`),
  KEY `mixin` (`mixin`)
) ENGINE=InnoDB AUTO_INCREMENT=10 ;

--
-- Contenu de la table `action`
--

INSERT INTO `action` (`id`, `category`, `kind`, `mixin`) VALUES
(1, 1, 4, NULL),
(2, 2, 4, NULL),
(3, 3, 4, NULL),
(4, 4, 5, NULL),
(5, 5, 5, NULL),
(6, 6, 5, NULL),
(7, 7, 5, NULL),
(8, 8, 5, NULL),
(9, 9, 5, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `autoscalinggroup`
--

CREATE TABLE IF NOT EXISTS `autoscalinggroup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text,
  `summary` text,
  `state` varchar(8) NOT NULL DEFAULT 'inactive',
  `size` int(11) NOT NULL DEFAULT '0',
  `min` int(11) NOT NULL DEFAULT '0',
  `max` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;




-- --------------------------------------------------------

--
-- Structure de la table `autoscalinggroup_extension`
--

CREATE TABLE IF NOT EXISTS `autoscalinggroup_extension` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `autoscalinggroup` int(11) NOT NULL,
  `mixin` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `autoscalinggroup` (`autoscalinggroup`),
  KEY `mixin` (`mixin`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;




-- --------------------------------------------------------

--
-- Structure de la table `category`
--

CREATE TABLE IF NOT EXISTS `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scheme` varchar(500) NOT NULL,
  `term` varchar(200) NOT NULL,
  `title` text,
  `attributes` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scheme` (`scheme`,`term`)
) ENGINE=InnoDB  AUTO_INCREMENT=10 ;



INSERT INTO `category` (`id`, `scheme`, `term`, `title`, `attributes`) VALUES
(1, 'http://schemas.ogf.org/serviceManager/service/action#', 'start', 'start', NULL),
(2, 'http://schemas.ogf.org/serviceManager/service/action#', 'stop', 'stop', NULL),
(3, 'http://schemas.ogf.org/serviceManager/service/action#', 'restart', 'restart', NULL),
(4, 'http://schemas.ogf.org/serviceManager/autoscalinggroup/action#', 'start', 'start', NULL),
(5, 'http://schemas.ogf.org/serviceManager/autoscalinggroup/action#', 'stop', 'stop', NULL),
(6, 'http://schemas.ogf.org/serviceManager/autoscalinggroup/action#', 'restart', 'restart', NULL),
(7, 'http://schemas.ogf.org/serviceManager/autoscalinggroup/action#', 'execute', 'execute', 'script'),
(8, 'http://schemas.ogf.org/serviceManager/autoscalinggroup/action#', 'increase', 'increase', 'size'),
(9, 'http://schemas.ogf.org/serviceManager/autoscalinggroup/action#', 'decrease', 'decrease', 'size');

-- --------------------------------------------------------

--
-- Structure de la table `dependence`
--

CREATE TABLE IF NOT EXISTS `dependence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text,
  `source` int(11) NOT NULL,
  `target` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `source` (`source`),
  KEY `target` (`target`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;




-- --------------------------------------------------------

--
-- Structure de la table `dependence_extension`
--

CREATE TABLE IF NOT EXISTS `dependence_extension` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dependence` int(11) NOT NULL,
  `mixin` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dependence` (`dependence`),
  KEY `mixin` (`mixin`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;




-- --------------------------------------------------------

--
-- Structure de la table `group`
--

CREATE TABLE IF NOT EXISTS `group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text,
  `source` int(11) NOT NULL,
  `target` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `source` (`source`),
  KEY `target` (`target`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;




-- --------------------------------------------------------

--
-- Structure de la table `group_extension`
--

CREATE TABLE IF NOT EXISTS `group_extension` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group` int(11) NOT NULL,
  `mixin` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `group` (`group`),
  KEY `mixin` (`mixin`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;


-- --------------------------------------------------------

--
-- Structure de la table `kind`
--

CREATE TABLE IF NOT EXISTS `kind` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scheme` varchar(500) NOT NULL,
  `term` varchar(16) NOT NULL,
  `title` text,
  `entity_type` text NOT NULL,
  `attributes` text,
  `related` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scheme` (`scheme`,`term`),
  KEY `related` (`related`)
) ENGINE=InnoDB AUTO_INCREMENT=8 ;

--
-- Contenu de la table `kind`
--

INSERT INTO `kind` (`id`, `scheme`, `term`, `title`, `entity_type`, `attributes`, `related`) VALUES
(1, 'http://schemas.ogf.org/occi/core#', 'entity', 'entity', 'Entity', 'occi.core.id,occi.core.title', NULL),
(2, 'http://schemas.ogf.org/occi/core#', 'resource', 'resource', 'Resource', 'occi.core.summary', 1),
(3, 'http://schemas.ogf.org/occi/core#', 'link', 'link', 'Link', '', 1),
(4, 'http://schemas.ogf.org/occi/serviceManager#', 'service', 'service', 'Service', 'occi.service.state', 2),
(5, 'http://schemas.ogf.org/occi/serviceManager#', 'autoscalinggroup', 'autoscaling group', 'AutoScalingGroup', 'occi.autoscalinggroup.state,occi.autoscalinggroup.size,occi.autoscalinggroup.min,occi.autoscalinggroup.max', 2),
(6, 'http://schemas.ogf.org/occi/serviceManager#', 'group', 'group', 'Group', NULL, 3),
(7, 'http://schemas.ogf.org/occi/serviceManager#', 'dependence', 'dependence', 'Dependence', NULL, 3);

-- --------------------------------------------------------

--
-- Structure de la table `mixin`
--

CREATE TABLE IF NOT EXISTS `mixin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text,
  `scheme` varchar(500) NOT NULL,
  `term` varchar(200) NOT NULL,
  `attributes` text,
  `kind` int(11) NOT NULL,
  `userMixin` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `scheme` (`scheme`,`term`),
  KEY `kind` (`kind`)
) ENGINE=InnoDB AUTO_INCREMENT=12 ;

--
-- Contenu de la table `mixin`
--

INSERT INTO `mixin` (`id`, `title`, `scheme`, `term`, `attributes`, `kind`, `userMixin`) VALUES
(1, 'rule_tpl', 'http://schemas.ogf.org/serviceManager/autoscalinggroup#', 'rule_tpl', 'occi.autoscalinggroup.url,occi.autoscalinggroup.rules', 5, 0),
(2, 'script_tpl', 'http://schemas.ogf.org/serviceManager/autoscalinggroup#', 'script_tpl', 'occi.autoscalinggroup.script,occi.autoscalinggroup.url,occi.autoscalinggroup.type,occi.autoscalinggroup.runlevel', 5, 0),
(3, 'nginx', 'http://localhost:9292/templates/autoscalinggroup#', 'nginx', 'occi.autoscalinggroup.script="apt-get install -q -y nginx\nfile=\\"/etc/nginx/nginx.conf\\"\nsed -i \\"/http\\s{/a   upstream myproject {\\n\\t\\t#service_managerx21\\n\\t}\\n\\n\\tserver{\\n\\t\\tlisten 80;\\n\\t\\tserver_name www.domain.com;\\n\\t\\tlocation / {\\n\\t\\t\\tproxy_pass http://myproject;\\n\\t\\t}\\n\\t}\\" $file\n/etc/init.d/nginx restart",occi.autoscalinggroup.url="",occi.autoscalinggroup.type="boot",occi.autoscalinggroup.runlevel=""', 5, 0),
(4, 'mysql', 'http://localhost:9292/templates/autoscalinggroup#', 'mysql', 'occi.autoscalinggroup.script="DEBIAN_FRONTEND=\\"noninteractive\\" apt-get install -q -y mysql-server\nmysqladmin -u root password $mysqlpass",occi.autoscalinggroup.url="",occi.autoscalinggroup.type="boot",occi.autoscalinggroup.runlevel="",mysqlpass="\\"servicemanager\\""', 5, 0),
(5, 'apache loabanlanced', 'http://localhost:9292/templates/autoscalinggroup#', 'apacheLB', 'occi.autoscalinggroup.script="apt-get install -q -y apache2\nadressIP=$(ifconfig eth0 | grep \\"inet ad\\" | sed \\"s/.*dr:\\([0-9]*\\.[0-9]*\\.[0-9]*\\.[0-9]*\\).*/\\1/\\")\necho \\"$adressIP\\" >> /var/www/index.html\ncom=\\"file=/etc/nginx/nginx.conf\\nsed -i \\\\"/#service_managerx21/a server $adressIP:80;\\\\" \\$file\\n/etc/init.d/nginx restart\\"\n/servman/client.rb \\"$com\\" ${loadbalancerIP[0]}",occi.autoscalinggroup.url="",occi.autoscalinggroup.type="boot",occi.autoscalinggroup.runlevel="",loadbalancerIP="Mx[http://localhost:9292/templates/autoscalinggroup#nginx,IP]"', 5, 0),
(6, 'os_tpl', 'http://schemas.ogf.org/occi/infrastructure#', 'os_tpl', NULL, 5, 0),
(7, 'Ubuntu server 10.10 amd64.', 'http://localhost:9292/templates/autoscalinggroup#', 'ubuntu', NULL, 5, 0),
(8, 'resource_tpl', 'http://schemas.ogf.org/occi/infrastructure#', 'resource_tpl', NULL, 5, 0),
(9, 'smallInstance', 'http://localhost:9292/templates/autoscalinggroup#', 'small', 'occi.compute.arch=x86,occi.compute.cores=2,occi.compute.speed=2.4,occi.compute.memory=1.0', 5, 0),
(10, 'mediumInstance', 'http://localhost:9292/templates/autoscalinggroup#', 'medium', 'occi.compute.arch=x86,occi.compute.cores=4,occi.compute.speed=2.4,occi.compute.memory=4.0', 5, 0),
(11, 'largeInstance', 'http://localhost:9292/templates/autoscalinggroup#', 'large', 'occi.compute.arch=x86,occi.compute.cores=8,occi.compute.speed=2.4,occi.compute.memory=8.0', 5, 0);

-- --------------------------------------------------------

--
-- Structure de la table `mixin_relation`
--

CREATE TABLE IF NOT EXISTS `mixin_relation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mixin` int(11) NOT NULL,
  `related` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mixin` (`mixin`),
  KEY `related` (`related`)
) ENGINE=InnoDB AUTO_INCREMENT=8 ;

--
-- Contenu de la table `mixin_relation`
--

INSERT INTO `mixin_relation` (`id`, `mixin`, `related`) VALUES
(1, 3, 2),
(2, 4, 2),
(3, 5, 2),
(4, 7, 6),
(5, 9, 8),
(6, 10, 8),
(7, 11, 8);

-- --------------------------------------------------------

--
-- Structure de la table `service`
--

CREATE TABLE IF NOT EXISTS `service` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text,
  `summary` text,
  `state` varchar(8) NOT NULL DEFAULT 'inactive',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;


-- --------------------------------------------------------

--
-- Structure de la table `service_extension`
--

CREATE TABLE IF NOT EXISTS `service_extension` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service` int(11) NOT NULL,
  `mixin` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service` (`service`),
  KEY `mixin` (`mixin`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;

--
-- Contenu de la table `service_extension`
--


-- --------------------------------------------------------

--
-- Structure de la table `vm`
--

CREATE TABLE IF NOT EXISTS `vm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text NOT NULL,
  `autoscalinggroup` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `autoscalinggroup` (`autoscalinggroup`)
) ENGINE=InnoDB AUTO_INCREMENT=1 ;


-- --------------------------------------------------------- --
--                    LISTE DES CONTRAINTES                  --
-- --------------------------------------------------------- --



--
-- Contraintes pour la table `action`
--
ALTER TABLE `action`
  ADD CONSTRAINT `action_ibfk_1` FOREIGN KEY (`category`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `action_ibfk_2` FOREIGN KEY (`kind`) REFERENCES `kind` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `action_ibfk_3` FOREIGN KEY (`mixin`) REFERENCES `mixin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `autoscalinggroup_extension`
--
ALTER TABLE `autoscalinggroup_extension`
  ADD CONSTRAINT `autoscalinggroup_extension_ibfk_1` FOREIGN KEY (`autoscalinggroup`) REFERENCES `autoscalinggroup` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `autoscalinggroup_extension_ibfk_2` FOREIGN KEY (`mixin`) REFERENCES `mixin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `dependence`
--
ALTER TABLE `dependence`
  ADD CONSTRAINT `dependence_ibfk_1` FOREIGN KEY (`source`) REFERENCES `autoscalinggroup` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dependence_ibfk_2` FOREIGN KEY (`target`) REFERENCES `autoscalinggroup` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `dependence_extension`
--
ALTER TABLE `dependence_extension`
  ADD CONSTRAINT `dependence_extension_ibfk_1` FOREIGN KEY (`dependence`) REFERENCES `dependence` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dependence_extension_ibfk_2` FOREIGN KEY (`mixin`) REFERENCES `mixin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `group`
--
ALTER TABLE `group`
  ADD CONSTRAINT `group_ibfk_1` FOREIGN KEY (`source`) REFERENCES `service` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `group_ibfk_2` FOREIGN KEY (`target`) REFERENCES `autoscalinggroup` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `group_extension`
--
ALTER TABLE `group_extension`
  ADD CONSTRAINT `group_extension_ibfk_1` FOREIGN KEY (`group`) REFERENCES `group` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `group_extension_ibfk_2` FOREIGN KEY (`mixin`) REFERENCES `mixin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `kind`
--
ALTER TABLE `kind`
  ADD CONSTRAINT `kind_ibfk_1` FOREIGN KEY (`related`) REFERENCES `kind` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `mixin`
--
ALTER TABLE `mixin`
  ADD CONSTRAINT `mixin_ibfk_1` FOREIGN KEY (`kind`) REFERENCES `kind` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `mixin_relation`
--
ALTER TABLE `mixin_relation`
  ADD CONSTRAINT `mixin_relation_ibfk_1` FOREIGN KEY (`mixin`) REFERENCES `mixin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mixin_relation_ibfk_2` FOREIGN KEY (`related`) REFERENCES `mixin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `service_extension`
--
ALTER TABLE `service_extension`
  ADD CONSTRAINT `service_extension_ibfk_1` FOREIGN KEY (`service`) REFERENCES `service` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `service_extension_ibfk_2` FOREIGN KEY (`mixin`) REFERENCES `mixin` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;



--
-- Contraintes pour la table `vm`
--
ALTER TABLE `vm`
  ADD CONSTRAINT `vm_ibfk_1` FOREIGN KEY (`autoscalinggroup`) REFERENCES `autoscalinggroup` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- --------------------------------------------------------- --
--                           FIN                             --
-- --------------------------------------------------------- --
