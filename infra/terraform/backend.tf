terraform {
  backend "gcs" {
    bucket = "homelab.middleearth.cc"
    prefix = "terraform/state"
  }
}
