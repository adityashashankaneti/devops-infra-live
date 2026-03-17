resource "aws_db_subnet_group" "this" {
  for_each = var.resources

  name       = "${each.key}-subnet-group"
  subnet_ids = [for s in each.value.subnet_names : lookup(var.subnet_ids, s, null)]

  tags = { Name = "${each.key}-subnet-group", Project = var.project, ManagedBy = "terraform" }
}

resource "aws_db_instance" "this" {
  for_each = var.resources

  identifier     = each.key
  engine         = try(each.value.engine, "mysql")
  engine_version = try(each.value.engine_version, null)
  instance_class = try(each.value.instance_class, "db.t3.micro")

  allocated_storage     = try(each.value.allocated_storage, 20)
  max_allocated_storage = try(each.value.max_allocated_storage, 100)
  storage_encrypted     = try(each.value.storage_encrypted, true)

  db_name  = try(each.value.db_name, null)
  username = each.value.username
  password = each.value.password

  multi_az            = try(each.value.multi_az, false)
  publicly_accessible = try(each.value.publicly_accessible, false)
  skip_final_snapshot = try(each.value.skip_final_snapshot, true)

  db_subnet_group_name   = aws_db_subnet_group.this[each.key].name
  vpc_security_group_ids = try([for sg in each.value.security_groups : var.security_group_ids[sg]], [])

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
