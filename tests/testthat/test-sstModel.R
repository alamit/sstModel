# unit tests for sstModel
context("S3 classe sstModel")

# checking constructor
test_that("sstModel is ok", {

  ## building marketRisk
  cov.mat <- diag(2, 4, 4) %*% diag(rep(1, 4))  %*% diag(2, 4, 4)
  name <- c("EURCHF", "equityCHF", "2YCHF", "AAACHF")
  colnames(cov.mat) <- name
  rownames(cov.mat) <- name
  attr(cov.mat, "base.currency") <- "CHF"


  mapping.table <- mappingTable(currency(name = "EURCHF",
                                         from = "EUR",
                                         to   = "CHF"),
                                equity(name     = "equityCHF",
                                       type     = "equity",
                                       currency = "CHF"),
                                rate(name     = "2YCHF",
                                     currency = "CHF",
                                     horizon  = "k"),
                                spread(name     = "AAACHF",
                                       currency = "CHF",
                                       rating   = "AAA"),
                                rate(name     = "2YCHF",
                                     currency = "EUR",
                                     horizon  = "k",
                                     scale    = 0.8))
  initial.values <- list()

  initial.values$initial.fx <- data.frame(from             = "EUR",
                                          to               = "CHF",
                                          fx               = 1.05,
                                          stringsAsFactors = F)

  initial.values$initial.rate <- data.frame(time             = 1L,
                                            currency         = c("CHF", "EUR"),
                                            rate             = c(0.01, 0.01),
                                            stringsAsFactors = F)

  mapping.time <- data.frame(time = 1L, mapping = "k", stringsAsFactors = F)

  ## define an economic scenario
  eco.table <- matrix(c(1,1,1,1,2,2,1,4,2,3), nrow=2)
  colnames(eco.table) <- c(name, "participation")
  rownames(eco.table) <- c("sc1","sc2")

  eco.scenario <- macroEconomicScenarios(macro.economic.scenario.table = eco.table)

  mr <- marketRisk(cov.mat                  = cov.mat,
                   mapping.table            = mapping.table,
                   initial.values           = initial.values,
                   mapping.time             = mapping.time,
                   base.currency            = "CHF")

  M <- matrix(c(1, 1, 1, 1), 2)
  colnames(M) <- c("storno", "invalidity")
  rownames(M) <- colnames(M)

  lr <- lifeRisk(corr.mat  = M,
                 quantile = c(0.995, 0.995))

  hr <- healthRisk(corr.mat  = M)

  valid.param <- list(mvm = 3,
                      rtkr = 0,
                      rtkg = 0,
                      credit.risk = 3,
                      correction.term = 3,
                      expected.insurance.result =  10^6,
                      expected.financial.result =  10^5)

  valid.param <- list(mvm = list(mvm.life = 2, mvm.health = 4, mvm.nonlife = 3),
                      rtkr = 0,
                      rtkg = 0,
                      credit.risk = 3,
                      correction.term = 3,
                      expected.insurance.result =  10^6,
                      expected.financial.result =  10^5)


  p <- portfolio(market.items = list(asset(type = "equity", currency = "CHF", value = 1000),
                                    liability(time = 1L, currency = "CHF", value = -400),
                                    cashflow(time = 1L, currency = "CHF", rating = "AAA", 0.06, value = 500),
                                    delta(name = "EURCHF", currency = "CHF", sensitivity = 30)),
                 participation.item = participation(currency = "CHF", value = 200),
                 life.item = life(name = c("storno", "invalidity"), currency = c("CHF", "CHF"), sensitivity = c(10, 10)),
                 health.item = health(name = c("storno", "invalidity"), currency = c("CHF", "CHF"), sensitivity = c(10, 10)),
                 base.currency = "CHF",
                 portfolio.parameters = valid.param)

  list.correlation.matrix <- list(base = matrix(c(1,0.15,0.075,0.15,
                                                  0.15,1,0.25,0.25,
                                                  0.075,0.25,1,0.15,
                                                  0.15,0.25,0.15,1), ncol=4, byrow = T),
                                  scenario1 = matrix(c(1,1,1,0.35,
                                                       1,1,1,0.35,
                                                       1,1,1,0.35,
                                                       0.35,0.35,0.35,1), ncol=4, byrow = T),
                                  scenario2 = matrix(c(1,0.6,0.5,0.25,
                                                       0.6,1,0.8,0.35,
                                                       0.5,0.8,1,0.35,
                                                       0.25,0.35,0.35,1), ncol=4, byrow = T),
                                  scenario3 = matrix(c(1,0.25,0.25,0.5,
                                                       0.25,1,0.25,0.25,
                                                       0.25,0.25,1,0.25,
                                                       0.5,0.25,0.25,1), ncol=4, byrow = T))

  list.correlation.matrix <- lapply(list.correlation.matrix, function(corr) {rownames(corr) <- colnames(corr) <- c("market", "life","health","nonlife"); corr})

  # define the region boundaries (i.e. the thresholds t)
  region.boundaries <- matrix(c(0.2,0.3,0.3,0.5,
                                0.5,0.2,0.2,0.8,
                                0.6,0.8,0.8,0.2), nrow=3, byrow = T)

  colnames(region.boundaries) <- c("market", "life","health","nonlife")
  rownames(region.boundaries) <- c("scenario1", "scenario2", "scenario3")

  # scenario and region probabilities
  scenario.probability  = c(0.01, 0.01, 0.01)
  region.probability  = c(0.023, 0.034, 0.107)


  model <- sstModel(portfolio = p,
                    market.risk = mr,
                    life.risk = lr,
                    health.risk = hr,
                    nonlife.risk =  nonLifeRisk(type     = "simulations",
                                               param    = list(simulations=c(1, 2, 3, 4)),
                                               currency = "CHF"),
                    scenario.risk = scenarioRisk("tornado", 0.08, "CHF", -10),
                    participation.risk = participationRisk(volatility = 3),
                    macro.economic.scenarios = eco.scenario,
                    nhmr = 0.06,
                    reordering.parameters = list(list.correlation.matrix = list.correlation.matrix,
                                                 region.boundaries = region.boundaries,
                                                 region.probability = region.probability,
                                                 scenario.probability = scenario.probability),
                    standalones = list(standalone(name = "equity", equity(name     = "equityCHF",
                                                                          type     = "equity",
                                                                          currency = "CHF")),
                                       standalone(name = "something", spread(name     = "AAACHF",
                                                                             currency = "CHF",
                                                                             rating   = "AAA"),
                                                  rate(name     = "2YCHF",
                                                       currency = "EUR",
                                                       horizon  = "k",
                                                       scale    = 0.8))))

  expect_error(sstModel(portfolio = p,
                        market.risk = mr,
                        life.risk = lr,
                        health.risk = hr,
                        nonlife.risk =  nonLifeRisk(type     = "simulations",
                                                   param    = list(simulations=c(1, 2, 3, 4)),
                                                   currency = "CHF"),
                        scenario.risk = scenarioRisk("tornado", 0.08, "CHF", -10),
                        participation.risk = participationRisk(volatility = 3),
                        macro.economic.scenarios = eco.scenario,
                        nhmr = 0.06,
                        reordering.parameters = list(list.correlation.matrix = list.correlation.matrix,
                                                     region.boundaries = region.boundaries,
                                                     region.probability = region.probability,
                                                     scenario.probability = scenario.probability),
                        standalones = list(standalone(name = "equity", equity(name     = "equityCHF",
                                                                              type     = "equity",
                                                                              currency = "CHF")),
                                           standalone(name = "something", spread(name     = "AAACHF",
                                                                                 currency = "CHF",
                                                                                 rating   = "AAA"),
                                                      rate(name     = "2YCHF",
                                                           currency = "EUR",
                                                           horizon  = "l")))),
               "standalones")


  expect_error(sstModel(portfolio = p,
                        market.risk = mr,
                        life.risk = NULL,
                        health.risk = hr,
                        nonlife.risk =  nonLifeRisk(type     = "simulations",
                                                   param    = list(simulations=c(1, 2, 3, 4)),
                                                   currency = "CHF"),
                        scenario.risk = scenarioRisk("tornado", 0.08, "EUR", -10),
                        participation.risk = participationRisk(volatility = 3),
                        macro.economic.scenarios = eco.scenario,
                        nhmr = 0.06,
                        reordering.parameters = list(list.correlation.matrix = list.correlation.matrix,
                                                     region.boundaries = region.boundaries,
                                                     region.probability = region.probability,
                                                     scenario.probability = scenario.probability),
                        standalones = list(standalone(name = "equity", equity(name     = "equityCHF",
                                                                              type     = "equity",
                                                                              currency = "CHF")),
                                           standalone(name = "something", spread(name     = "AAACHF",
                                                                                 currency = "CHF",
                                                                                 rating   = "AAA"),
                                                      rate(name     = "2YCHF",
                                                           currency = "EUR",
                                                           horizon  = "k",
                                                           scale    = 0.8)))),
               "Missing")

  expect_error(sstModel(portfolio = p,
                        market.risk = mr,
                        life.risk = lr,
                        health.risk = NULL,
                        nonlife.risk = NULL,
                        scenario.risk = scenarioRisk("tornado", 0.08, "EUR", -10),
                        participation.risk = participationRisk(volatility = 3),
                        macro.economic.scenarios = eco.scenario,
                        nhmr = 0.06,
                        reordering.parameters = list(list.correlation.matrix = list.correlation.matrix,
                                                     region.boundaries = region.boundaries,
                                                     region.probability = region.probability,
                                                     scenario.probability = scenario.probability),
                        standalones = list(standalone(name = "equity", equity(name     = "equityCHF",
                                                                              type     = "equity",
                                                                              currency = "CHF")),
                                           standalone(name = "something", spread(name     = "AAACHF",
                                                                                 currency = "CHF",
                                                                                 rating   = "AAA"),
                                                      rate(name     = "2YCHF",
                                                           currency = "EUR",
                                                           horizon  = "k",
                                                           scale    = 0.8)))),
               "Missing")

})

