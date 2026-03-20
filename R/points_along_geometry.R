#' Sample points along geometries
#'
#' Samples points along supported geometry parts at a fixed distance.
#'
#' @param geom A [GEOS geometry vector][geos::as_geos_geometry].
#' @param distance Distance between sampled points.
#' @param start_offset Distance to skip from the start of each part.
#' @param end_offset Distance to skip from the end of each part.
#'
#' @return A [GEOS geometry vector][geos::as_geos_geometry] of multipoints.
#' @export
geos_points_along_geometry <-
  function(
    geom,
    distance,
    start_offset = 0,
    end_offset = 0
  ) {
    checkmate::assert_multi_class(geom, c("geos_geometry", "wk_xy"))
    
    checkmate::assert_number(distance, finite = TRUE, lower = 0)
    checkmate::assert_true(distance > 0)
    checkmate::assert_number(start_offset, finite = TRUE, lower = 0)
    checkmate::assert_number(end_offset, finite = TRUE, lower = 0)

    if (!length(geom)) {
      return(geom)
    }

    empty_multipoint <- geos::as_geos_geometry("MULTIPOINT EMPTY")
    out <- vector("list", length(geom))
    unsampleable_parts <- 0L
    unsampleable_features <- 0L

    for (i in seq_along(geom)) {
      feature <- geom[i]

      if (is.na(feature) || geos::geos_is_empty(feature)) {
        out[[i]] <- empty_multipoint
        unsampleable_features <- unsampleable_features + 1L
        next
      }

      feature_type <- geos::geos_type(feature)
      if (feature_type %in% c("linestring", "linearring", "polygon")) {
        parts <- feature
      } else if (
        feature_type %in%
          c("multilinestring", "multipolygon", "geometrycollection")
      ) {
        parts <- geos::geos_unnest(feature, keep_multi = FALSE, max_depth = 99)
      } else {
        stop("Unsupported geometry part: ", feature_type, call. = FALSE)
      }

      feature_points <- list()

      for (j in seq_along(parts)) {
        part <- parts[j]
        part_type <- geos::geos_type(part)

        if (part_type %in% c("linestring", "linearring")) {
          pts <- sample_part_line(part, distance, start_offset, end_offset)
          if (length(pts)) {
            feature_points[[length(feature_points) + 1L]] <- pts
          } else {
            unsampleable_parts <- unsampleable_parts + 1L
          }
          next
        }

        if (part_type == "polygon") {
          coords <- wk::wk_coords(part)

          for (ring_id in unique(coords$ring_id)) {
            ring <- coords[coords$ring_id == ring_id, , drop = FALSE]
            pts <- sample_coords_line(
              ring,
              distance,
              start_offset,
              end_offset,
              closed = TRUE
            )
            if (length(pts)) {
              feature_points[[length(feature_points) + 1L]] <- pts
            } else {
              unsampleable_parts <- unsampleable_parts + 1L
            }
          }

          next
        }

        stop("Unsupported geometry part: ", part_type, call. = FALSE)
      }

      if (!length(feature_points)) {
        out[[i]] <- empty_multipoint
        unsampleable_features <- unsampleable_features + 1L
        next
      }

      points <- do.call(c, feature_points)
      points <- points[!duplicated(geos::geos_write_wkt(points))]

      if (!length(points)) {
        out[[i]] <- empty_multipoint
        unsampleable_features <- unsampleable_features + 1L
        next
      }

      out[[i]] <- geos::geos_make_collection(points, type_id = "multipoint")
    }

    if (unsampleable_parts > 0L || unsampleable_features > 0L) {
      warning(
        sprintf(
          "%d unsampleable parts across %d unsampleable features",
          unsampleable_parts,
          unsampleable_features
        ),
        call. = FALSE
      )
    }

    do.call(c, out)
  }

sample_part_line <- function(part, distance, start_offset, end_offset) {
  coords <- wk::wk_coords(part)
  sample_coords_line(
    coords,
    distance,
    start_offset,
    end_offset,
    closed = geos::geos_type(part) == "linearring" ||
      isTRUE(geos::geos_is_closed(part))
  )
}

sample_coords_line <- function(
  coords,
  distance,
  start_offset,
  end_offset,
  closed
) {
  line <- if ("z" %in% names(coords)) {
    geos::geos_make_linestring(coords$x, coords$y, coords$z)
  } else {
    geos::geos_make_linestring(coords$x, coords$y)
  }

  part_length <- geos::geos_length(line)
  tol <- sqrt(.Machine$double.eps) *
    max(1, part_length, distance, start_offset, end_offset)

  if (part_length <= tol || start_offset + end_offset > part_length + tol) {
    return(geos::as_geos_geometry(character()))
  }

  end <- max(start_offset, part_length - end_offset)
  d <- seq(start_offset, end, by = distance)

  if (!length(d)) {
    return(geos::as_geos_geometry(character()))
  }

  if (closed) {
    d <- d[d < (end - tol)]
  } else if (abs(d[length(d)] - end) <= tol) {
    d[length(d)] <- end
  }

  if (!length(d)) {
    return(geos::as_geos_geometry(character()))
  }

  geos::geos_interpolate(line, d)
}
