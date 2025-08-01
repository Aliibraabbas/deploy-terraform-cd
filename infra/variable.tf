variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "bucket_name" {
  type        = string
  description = "The bucket name"
  default     = "archidevopsiimwebsite"
}

variable "tags" {
  type = object({
    Name        = string
    Environment = string
  })
  default = {
    Name        = "archidevops-tp5"
    Environment = "dev"
    # Deployment = "Terraform"
  }
}



variable "mime_types" {
  description = "Mapping of file extensions to their respective MIME (Multipurpose Internet Mail Extensions) types. This helps in determining the nature and format of a document."
  type        = map(string)
  default = {
    htm  = "text/html"
    html = "text/html"
    css  = "text/css"
    ttf  = "font/ttf"
    js   = "application/javascript"
    map  = "application/javascript"
    json = "application/json"
  }
}

variable "sync_directories" {
  type = list(object({
    local_source_directory = string
    s3_target_directory    = string
  }))
  description = "List of directories to synchronize with Amazon S3."
  default = [{
    local_source_directory = "../client/dist"
    s3_target_directory    = ""
  }]
}


variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
}

variable "client_image_tag" {
  description = "Frontend image tag"
  type        = string
}

variable "server_image_tag" {
  description = "Backend image tag"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ECS tasks"
  type        = list(string)
}
