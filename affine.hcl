name = "alpha"
services = [
  {
    name  = "abbey-wood",
    image = "ghcr.io/toeverything/affine-self-hosted",
    tag   = "alpha-abbey-wood",
    ports = [{ name = "abbey-wood", to = "3000" }],
  }
]
