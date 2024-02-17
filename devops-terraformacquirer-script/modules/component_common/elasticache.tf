#####################################################################
# CRIA O ELASTICACHE POR NAMESPACE
#####################################################################
locals {
  enabled_elasticache = try(var.environmentConfig["elasticache"], false)
}

resource "aws_elasticache_subnet_group" "default" {
 count      = local.enabled_elasticache ? 1 : 0
 name       = "${var.namespace}-elasticache"
 subnet_ids = var.private_subnets_ids

 tags = {
    Service   = "elasticache"
    Component = "common"
 }
}

resource "aws_elasticache_cluster" "default" {
 count                = local.enabled_elasticache ? 1 : 0
 cluster_id           = "${var.namespace}-elasticache"
 engine               = "redis"
 node_type            = "cache.t4g.micro"
 num_cache_nodes      = 1
 parameter_group_name = "default.redis6.x"

 apply_immediately        = true
 engine_version           = "6.x"
 maintenance_window       = "tue:05:00-tue:06:00"
 port                     = 6379
 security_group_ids       = [aws_security_group.elasticache[0].id]
 snapshot_retention_limit = 0
 subnet_group_name        = aws_elasticache_subnet_group.default[0].name

 tags = {
    Service   = "elasticache"
    Component = "common"
 }
}

#####################################################################
# ELASTICACHE SECURITY GROUP
#####################################################################
resource "aws_security_group" "elasticache" {
 count       = local.enabled_elasticache ? 1 : 0
 name        = "${var.namespace}-elasticache"
 description = "Controla trafego para o elasticache"
 vpc_id      = var.vpc

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
   description = "Permite trafego indo para qualquer lugar"
 }

 tags = {
    Service   = "elasticache"
    Component = "common"
 }
}

resource "aws_security_group_rule" "elasticache_eks_cluster" {
 count                    = local.enabled_elasticache ? 1 : 0
 type                     = "ingress"
 from_port                = "6379"
 to_port                  = "6379"
 protocol                 = "tcp"
 security_group_id        = aws_security_group.elasticache[0].id
 source_security_group_id = data.aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
 description              = "Permite que as instancias do cluster EKS conectem no Elasticache"
}