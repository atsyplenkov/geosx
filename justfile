_default:
    just --list

# Format R code
fmt:
    air format .

# Run jarl linter
lint:
    jarl check . --fix --allow-dirty || true

# Update R documentation
document:
    Rscript -e "devtools::document()"

# Build and test the R package
test:
    #!/usr/bin/env bash
    R CMD build .
    R CMD check --as-cran --no-manual geosx_*.tar.gz
    rm -rf geosx_*.tar.gz geosx.Rcheck

install:
    #!/usr/bin/env bash
    rm geosx_*.tar.gz
    R CMD build .
    R CMD INSTALL geosx_*.tar.gz
    rm geosx_*.tar.gz
