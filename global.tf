locals {
  product_information = {
    context : {
      project    = "marc_gavanier"
      layer      = "infrastructure"
      service    = "network"
      start_date = "2022-08-12"
      end_date   = "unknown"
    }
    purpose : {
      disaster_recovery = "medium"
      service_class     = "bronze"
    }
    organization : {
      client = "marc.gavanier"
    }
    stakeholders : {
      business_owner  = "marc.gavanier@gmail.com"
      technical_owner = "marc.gavanier@gmail.com"
      approver        = "marc.gavanier@gmail.com"
      creator         = "terraform"
      team            = "marc-gavanier"
    }
  }
}

locals {
  projectTitle = title(replace(local.product_information.context.project, "_", " "))
  layerTitle   = title(replace(local.product_information.context.layer, "_", " "))
  serviceTitle = title(replace(local.product_information.context.service, "_", " "))
  domainNames  = ["marc.gavanier.io"]
}

locals {
  service = {
    name = "marc_gavanier"
    website = {
      name  = "website"
      title = "website"
    }
  }
}
