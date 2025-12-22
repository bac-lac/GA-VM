data "aws_lb" "ga_alb"{
  name = "ga-alb-${var.ENV}"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.ga_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "MFT-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  tags = { Name = "MFT-tg" }
}

resource "aws_lb_target_group_attachment" "tga" {
  count            = 2
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}

resource "aws_lb_listener" "https" {
  load_balancer_arn   = data.aws_lb.ga_alb.arn
  port                = "443"
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  certificate_arn     = aws_acm_certificate.baclacgcca.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Default response content"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "admin_rule" {
  listener_arn        = aws_lb_listener.https.arn
  action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.ga_tg_443.arn
  }
  condition {
    host_header {
      values          = ["goanywhere-${var.ENV}.bac-lac.gc.ca"]
    }
  }
  tags = {
    Name = "Admin-${var.ENV}"
  }
}

resource "aws_lb_target_group" "ga_tg_443" {
  name        = "ga-tg-${var.ENV}-443"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id
  health_check {
    path      = "/"
    matcher   = "200,302"
    port      = 8001
    protocol  = "HTTPS"
  }
  stickiness {
    enabled   = true
    type      = "lb_cookie"
  }
  tags = {
    Name = "Admin-${var.ENV}"
  }
}

resource "aws_lb_target_group_attachment" "tga_443" {
  count            = 2
  target_group_arn = aws_lb_target_group.ga_tg_443.arn
  target_id        = aws_instance.app[count.index].id
  port             = 443
}

/*

resource "aws_lb_listener_rule" "admin_internal_rule" {
  listener_arn        = aws_lb_listener.https.arn
  action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.ga_tg_443.arn
  }
  condition {
    host_header {
      values          = ["ga-${var.ENV}-internal.bac-lac.gc.ca"]
    }
  }
  tags = {
    Name = "Admin-Internal-${var.ENV}"
  }
}

resource "aws_lb_listener_rule" "web_client_rule" {
  listener_arn        = aws_lb_listener.https.arn
  action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.ga_tg_8443.arn
  }
  condition {
    host_header {
      values          = ["transfert-transfer-${var.ENV}.bac-lac.gc.ca"]
    }
  }
  tags = {
    Name = "Web-Client-${var.ENV}"
  }
}

resource "aws_lb_target_group" "ga_tg_443" {
  name        = "ga-tg-${var.ENV}-443"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
  health_check {
    path      = "/"
    matcher   = "200,302"
    port      = 8001
    protocol  = "HTTPS"
  }
  stickiness {
    enabled   = true
    type      = "lb_cookie"
  }
  tags = {
    Name = "Admin-${var.ENV}"
  }
}

resource "aws_lb_target_group" "ga_tg_8443" {
  name        = "ga-tg-${var.ENV}-8443"
  port        = 8443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
  health_check {
    path      = "/"
    matcher   = "200,302"
    port      = 8443
    protocol  = "HTTPS"
  }
  stickiness {
    enabled   = true
    type      = "lb_cookie"
  }
  tags = {
    Name = "Web-client-${var.ENV}"
  }
}

data "aws_lb" "ga_nlb"{
  name = "ga-nlb-${var.ENV}"
}

resource "aws_lb_listener" "sftp" {
  load_balancer_arn   = data.aws_lb.ga_nlb.arn
  port                = "22"
  protocol            = "TCP"
  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.ga_tg_22.arn
  }
  tags = {
    Name = "SFTP-${var.ENV}"
  }
}

resource "aws_lb_target_group" "ga_tg_22" {
  name        = "ga-tg-${var.ENV}-22"
  port        = 22
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
  health_check {
    port      = 8022
    protocol  = "TCP"
  }
  tags = {
    Name = "SFTP-${var.ENV}"
  }
} */