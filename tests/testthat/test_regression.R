## Tests for random forests for regression

library(ranger)
context("ranger_reg")

## Initialize the random forest for regression
rg.reg <- ranger(Sepal.Length ~ ., data = iris)

## Basic tests (for all random forests equal)
test_that("regression result is of class ranger with 16 elements", {
  expect_is(rg.reg, "ranger")
  expect_equal(length(rg.reg), 16)
})

test_that("regression prediction returns numeric vector", {
  expect_is(rg.reg$predictions, "numeric")
  expect_null(dim(rg.reg$predictions))
  
  pred <- predict(rg.reg, iris)
  expect_is(pred$predictions, "numeric")
  expect_null(dim(pred$predictions))
})

test_that("results have 500 trees", {
  expect_equal(rg.reg$num.trees, 500)
})

test_that("results have right number of independent variables", {
  expect_equal(rg.reg$num.independent.variables, ncol(iris) - 1)
})

test_that("Alternative interface works for regression", {
  rf <- ranger(dependent.variable.name = "Sepal.Length", data = iris)
  expect_equal(rf$treetype, "Regression")
})

test_that("Matrix interface works for regression", {
  rf <- ranger(dependent.variable.name = "Sepal.Length", data = data.matrix(iris), write.forest = TRUE)
  expect_equal(rf$treetype, "Regression")
  expect_equal(rf$forest$independent.variable.names, colnames(iris)[2:5])
})

test_that("Matrix interface prediction works for regression", {
  dat <- data.matrix(iris)
  rf <- ranger(dependent.variable.name = "Sepal.Length", data = dat, write.forest = TRUE)
  expect_silent(predict(rf, dat))
})

test_that("save.memory option works for regression", {
  rf <- ranger(Sepal.Length ~ ., data = iris, save.memory = TRUE)
  expect_equal(rf$treetype, "Regression")
})

test_that("predict.all for regression returns numeric matrix of size n x trees", {
  rf <- ranger(Petal.Width ~ ., iris, num.trees = 5, write.forest = TRUE)
  pred <- predict(rf, iris, predict.all = TRUE)
  expect_is(pred$predictions, "matrix")
  expect_equal(dim(pred$predictions), 
              c(nrow(iris), rf$num.trees))
})

test_that("Mean of predict.all for regression is equal to forest prediction", {
  rf <- ranger(Petal.Width ~ ., iris, num.trees = 5, write.forest = TRUE)
  pred_forest <- predict(rf, iris, predict.all = FALSE)
  pred_trees <- predict(rf, iris, predict.all = TRUE)
  expect_equal(rowMeans(pred_trees$predictions), pred_forest$predictions)
})

test_that("Alternative interface regression prediction works if only independent variable given, one independent variable", {
  n <- 50
  
  dt <- data.frame(x = runif(n), y = rbinom(n, 1, 0.5))
  rf <- ranger(dependent.variable.name = "y", data = dt, num.trees = 5, write.forest = TRUE)
  expect_silent(predict(rf, dt))
  expect_silent(predict(rf, dt[, 1, drop = FALSE]))
  
  dt2 <- data.frame(y = rbinom(n, 1, 0.5), x = runif(n))
  rf <- ranger(dependent.variable.name = "y", data = dt2, num.trees = 5, write.forest = TRUE)
  expect_silent(predict(rf, dt2))
  expect_silent(predict(rf, dt2[, 2, drop = FALSE]))
})

test_that("Alternative interface regression prediction works if only independent variable given, two independent variables", {
  n <- 50
  
  dt <- data.frame(x1 = runif(n), x2 = runif(n), y = rbinom(n, 1, 0.5))
  rf <- ranger(dependent.variable.name = "y", data = dt, num.trees = 5, write.forest = TRUE)
  expect_silent(predict(rf, dt))
  expect_silent(predict(rf, dt[, 1:2]))
  
  dt2 <- data.frame(y = rbinom(n, 1, 0.5), x1 = runif(n), x2 = runif(n))
  rf <- ranger(dependent.variable.name = "y", data = dt2, num.trees = 5, write.forest = TRUE)
  expect_silent(predict(rf, dt2))
  expect_silent(predict(rf, dt2[, 2:3]))
})

test_that("Alternative interface regression prediction: Results not all the same", {
  n <- 50
  
  dt <- data.frame(x = runif(n), y = rbinom(n, 1, 0.5))
  rf <- ranger(dependent.variable.name = "y", data = dt, num.trees = 5, write.forest = TRUE)
  expect_gt(diff(range(predict(rf, dt)$predictions)), 0)
  expect_gt(diff(range(predict(rf, dt[, 1, drop = FALSE])$predictions)), 0)
  
  dt2 <- data.frame(y = rbinom(n, 1, 0.5), x = runif(n))
  rf <- ranger(dependent.variable.name = "y", data = dt2, num.trees = 5, write.forest = TRUE)
  expect_gt(diff(range(predict(rf, dt2)$predictions)), 0)
  expect_gt(diff(range(predict(rf, dt2[, 2, drop = FALSE])$predictions)), 0)
})

## Special tests for random forests for regression
test_that("Variance splitting not working on classification data", {
  expect_error(ranger(Species ~ ., iris, splitrule = "variance"))
})

## Splitrule
test_that("default splitrule is variance for regression", {
  set.seed(42)
  rf1 <- ranger(Sepal.Length ~ ., iris, num.trees = 5)
  
  set.seed(42)
  rf2 <- ranger(Sepal.Length ~ ., iris, num.trees = 5, splitrule = "variance")
  
  expect_equal(rf1$splitrule, "variance")
  expect_equal(rf2$splitrule, "variance")
  expect_equal(rf1$prediction.error, rf2$prediction.error)
})

test_that("splitrule extratrees is different from variance for regression", {
  set.seed(42)
  rf1 <- ranger(Sepal.Length ~ ., iris, num.trees = 5, splitrule = "extratrees")
  
  set.seed(42)
  rf2 <- ranger(Sepal.Length ~ ., iris, num.trees = 5, splitrule = "variance")
  
  expect_equal(rf1$splitrule, "extratrees")
  expect_equal(rf2$splitrule, "variance")
  expect_false(rf1$prediction.error == rf2$prediction.error)
})

test_that("splitrule maxstat is different from variance for regression", {
  set.seed(42)
  rf1 <- ranger(Sepal.Length ~ ., iris, num.trees = 5, splitrule = "maxstat")
  
  set.seed(42)
  rf2 <- ranger(Sepal.Length ~ ., iris, num.trees = 5, splitrule = "variance")
  
  expect_equal(rf1$splitrule, "maxstat")
  expect_equal(rf2$splitrule, "variance")
  expect_false(rf1$prediction.error == rf2$prediction.error)
})


