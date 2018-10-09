include("helper.jl")

include("SocioEconomicComponent.jl")
include("PopulationComponent.jl")
include("EmissionsComponent.jl")
include("GeographyComponent.jl")
include("ScenarioUncertaintyComponent.jl")
include("ClimateCO2CycleComponent.jl")
include("ClimateCH4CycleComponent.jl")
include("ClimateN2OCycleComponent.jl")
include("ClimateSF6CycleComponent.jl")
include("ClimateForcingComponent.jl")
include("ClimateDynamicsComponent.jl")
include("BioDiversityComponent.jl")
include("ClimateRegionalComponent.jl")
include("OceanComponent.jl")
include("ImpactAgricultureComponent.jl")
include("ImpactBioDiversityComponent.jl")
include("ImpactCardiovascularRespiratoryComponent.jl")
include("ImpactCoolingComponent.jl")
include("ImpactDiarrhoeaComponent.jl")
include("ImpactExtratropicalStormsComponent.jl")
include("ImpactDeathMorbidityComponent.jl")
include("ImpactForestsComponent.jl")
include("ImpactHeatingComponent.jl")
include("ImpactVectorBorneDiseasesComponent.jl")
include("ImpactTropicalStormsComponent.jl")
include("ImpactWaterResourcesComponent.jl")
include("ImpactSeaLevelRiseComponent.jl")
include("ImpactAggregationComponent.jl")
include("VslVmorbComponent.jl")
include("MigrationComponent.jl")

function constructfund(;nsteps=1050)
    m = Model()

    setindex(m, :time, collect(1950:1950+nsteps))
    setindex(m, :regions, ["USA", "CAN", "WEU", "JPK", "ANZ", "EEU", "FSU", "MDE", "CAM", "LAM", "SAS", "SEA", "CHI", "NAF", "SSA", "SIS"])
    setindex(m, :iso2c, ["AF","AL","DZ","AS","AD","AO","AI","AG","AR","AM","AW","AU","AT","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BM","BT","BO","BA","BW","BV","BR","IO","BN","BG","BF","BI","CV","KH","CM","CA","KY","CF","TD","CL","CN","CX","CC","CO","KM","CG","CD","CK","CR","CI","HR","CU","CY","CZ","DK","DJ","DM","DO","EC","EG","SV","GQ","ER","EE","ET","FK","FO","FJ","FI","FR","GF","PF","TF","GA","GM","GZ","GE","DE","GH","GI","GR","GL","GD","GP","GU","GT","GG","GN","GW","GY","HT","HM","VA","HN","HK","HU","IS","IN","ID","IR","IQ","IE","IM","IL","IT","JM","JP","JE","JO","KZ","KE","KI","XK","KW","KG","LA","LV","LB","LS","LR","LY","LI","LT","LU","MO","MK","MG","MW","MY","MV","ML","MT","MH","MQ","MR","MU","YT","MX","FM","MD","MC","MN","ME","MS","MA","MZ","MM","NA","NR","NP","NL","AN","NC","NZ","NI","NE","NG","NU","NF","KP","MP","NO","OM","PK","PW","PS","PA","PG","PY","PE","PH","PN","PL","PT","PR","QA","RE","RO","RU","RW","SH","KN","LC","PM","VC","WS","SM","ST","SA","SN","RS","SC","SL","SG","SK","SI","SB","SO","ZA","GS","KR","ES","LK","SD","SR","SJ","SZ","SE","CH","SY","TW","TJ","TZ","TH","TL","TG","TK","TO","TT","TN","TR","TM","TC","TV","UG","UA","AE","GB","UM","US","UY","UZ","VU","VE","VN","VG","VI","WF","EH","YE","ZM","ZW"])
    setindex(m, :iso3c, ["AFG","ALB","ARE","ASM","AND","AGO","AIA","ATG","ARG","ARM","ABW","AUS","AUT","AZE","BHS","BHR","BGD","BRB","BLR","BEL","BLZ","BEN","BMU","BTN","BOL","BIH","BWA","BVT","BRA","IOT","BRN","BGR","BFA","BDI","CPV","KHM","CMR","CAN","CYM","CAF","TCD","CHL","CHN","CXR","CCK","COL","COM","COG","COD","COK","CRI","CIV","HRV","CUB","CYP","CZE","DNK","DJI","DMA","DOM","ECU","EGY","SLV","GNQ","ERI","EST","ETH","FLK","FRO","FJI","FIN","FRA","GUF","PYF","ATF","GAB","GMB","GAZ","GEO","DEU","GHA","GIB","GRC","GRL","GRD","GLP","GUM","GTM","GGY","GIN","GNB","GUY","HTI","HMD","VAT","HND","HKG","HUN","ISL","IND","IDN","IRN","IRQ","IRL","IMN","ISR","ITA","JAM","JPN","JEY","JOR","KAZ","KEN","KIR","XKX","KWT","KGZ","LAO","LVA","LBN","LSO","LBR","LBY","LIE","LTU","LUX","MAC","MKD","MDG","MWI","MYS","MDV","MLI","MLT","MHL","MTQ","MRT","MUS","MYT","MEX","FSM","MDA","MCO","MNG","MNE","MSR","MAR","MOZ","MMR","NAM","NRU","NPL","NLD","ANT","NCL","NZL","NIC","NER","NGA","NIU","NFK","PRK","MNP","NOR","OMN","PAK","PLW","PSE","PAN","PNG","PRY","PER","PHL","PCN","POL","PRT","PRI","QAT","REU","ROU","RUS","RWA","SHN","KNA","LCA","SPM","VCT","WSM","SMR","STP","SAU","SEN","SRB","SYC","SLE","SGP","SVK","SVN","SLB","SOM","ZAF","SGS","KOR","ESP","LKA","SDN","SUR","SJM","SWZ","SWE","CHE","SYR","TWN","TJK","TZA","THA","TLS","TGO","TKL","TON","TTO","TUN","TUR","TKM","TCA","TUV","UGA","UKR","DZA","GBR","UMI","USA","URY","UZB","VUT","VEN","VNM","VGB","VIR","WLF","ESH","YEM","ZMB","ZWE"])
    setindex(m, :isonum, [4,8,12,16,20,24,660,28,32,51,533,36,40,31,44,48,50,52,112,56,84,204,60,64,68,70,72,74,76,86,96,100,854,108,132,116,120,124,136,140,148,152,156,162,166,170,174,178,180,184,188,384,191,192,196,203,208,262,212,214,218,818,222,226,232,233,231,238,234,242,246,250,254,258,260,266,270,274,268,276,288,292,300,304,308,312,316,320,831,324,624,328,332,334,336,340,344,348,352,356,360,364,368,372,833,376,380,388,392,832,400,398,404,296,414,417,418,428,422,426,430,434,438,440,442,446,807,450,454,458,462,466,470,584,474,478,480,175,484,954,498,492,496,499,500,504,508,104,516,520,524,528,530,540,554,558,562,566,570,574,408,580,578,512,586,585,275,591,598,600,604,608,612,616,620,630,634,638,642,643,646,654,659,662,666,670,882,674,678,682,686,688,690,694,702,703,705,90,706,710,239,410,724,144,729,740,744,748,752,756,760,158,762,834,764,626,768,772,776,780,788,792,795,796,798,800,804,784,826,581,840,858,860,548,862,704,92,850,876,732,887,894,716])

    # ---------------------------------------------
    # Create components
    # ---------------------------------------------
    addcomponent(m, scenariouncertainty, :scenariouncertainty)
    addcomponent(m, population, :population)
    addcomponent(m, geography, :geography)
    addcomponent(m, socioeconomic, :socioeconomic)
    addcomponent(m, migration, :migration)
    addcomponent(m, emissions, :emissions)
    addcomponent(m, climateco2cycle, :climateco2cycle)
    addcomponent(m, climatech4cycle, :climatech4cycle)
    addcomponent(m, climaten2ocycle, :climaten2ocycle)
    addcomponent(m, climatesf6cycle, :climatesf6cycle)
    addcomponent(m, climateforcing, :climateforcing)
    addcomponent(m, climatedynamics, :climatedynamics)
    addcomponent(m, biodiversity, :biodiversity)
    addcomponent(m, climateregional, :climateregional)
    addcomponent(m, ocean, :ocean)
    addcomponent(m, impactagriculture, :impactagriculture)
    addcomponent(m, impactbiodiversity, :impactbiodiversity)
    addcomponent(m, impactcardiovascularrespiratory, :impactcardiovascularrespiratory)
    addcomponent(m, impactcooling, :impactcooling)
    addcomponent(m, impactdiarrhoea, :impactdiarrhoea)
    addcomponent(m, impactextratropicalstorms, :impactextratropicalstorms)
    addcomponent(m, impactforests, :impactforests)
    addcomponent(m, impactheating, :impactheating)
    addcomponent(m, impactvectorbornediseases, :impactvectorbornediseases)
    addcomponent(m, impacttropicalstorms, :impacttropicalstorms)
    addcomponent(m, vslvmorb, :vslvmorb)
    addcomponent(m, impactdeathmorbidity, :impactdeathmorbidity)
    addcomponent(m, impactwaterresources, :impactwaterresources)
    addcomponent(m, impactsealevelrise, :impactsealevelrise)
    addcomponent(m, impactaggregation, :impactaggregation)

    # ---------------------------------------------
    # Connect parameters to variables
    # ---------------------------------------------

    connectparameter(m, :geography, :landloss, :impactsealevelrise, :landloss)

    connectparameter(m, :population, :pgrowth, :scenariouncertainty, :pgrowth)
    connectparameter(m, :population, :enterSLR, :impactsealevelrise, :enterSLR)
    connectparameter(m, :population, :leaveSLR, :impactsealevelrise, :leaveSLR)
    connectparameter(m, :population, :dead, :impactdeathmorbidity, :dead)
    connectparameter(m, :population, :enter, :migration, :enter)
    connectparameter(m, :population, :leave, :migration, :leave)
    connectparameter(m, :population, :migdead, :migration, :migdead)

    connectparameter(m, :socioeconomic, :area, :geography, :area)
    connectparameter(m, :socioeconomic, :globalpopulation, :population, :globalpopulation)
    connectparameter(m, :socioeconomic, :populationin1, :population, :populationin1)
    connectparameter(m, :socioeconomic, :population, :population, :population)
    connectparameter(m, :socioeconomic, :pgrowth, :scenariouncertainty, :pgrowth)
    connectparameter(m, :socioeconomic, :ypcgrowth, :scenariouncertainty, :ypcgrowth)

    connectparameter(m, :socioeconomic, :eloss, :impactaggregation, :eloss)
    connectparameter(m, :socioeconomic, :sloss, :impactaggregation, :sloss)
    connectparameter(m, :socioeconomic, :mitigationcost, :emissions, :mitigationcost)
    connectparameter(m, :socioeconomic, :remittances, :migration, :remittances)
    connectparameter(m, :socioeconomic, :migrationcost, :migration, :migrationcost)
    connectparameter(m, :socioeconomic, :migdeadcost, :migration, :migdeadcost)

    connectparameter(m, :migration, :population, :population, :population)
    connectparameter(m, :migration, :income, :socioeconomic, :income)
    connectparameter(m, :migration, :vsl, :vslvmorb, :vsl)

    connectparameter(m, :emissions, :income, :socioeconomic, :income)
    connectparameter(m, :emissions, :population, :population, :population)
    connectparameter(m, :emissions, :forestemm, :scenariouncertainty, :forestemm)
    connectparameter(m, :emissions, :aeei, :scenariouncertainty, :aeei)
    connectparameter(m, :emissions, :acei, :scenariouncertainty, :acei)
    connectparameter(m, :emissions, :ypcgrowth, :scenariouncertainty, :ypcgrowth)

    connectparameter(m, :climateco2cycle, :mco2, :emissions, :mco2)

    connectparameter(m, :climatech4cycle, :globch4, :emissions, :globch4)

    connectparameter(m, :climaten2ocycle, :globn2o, :emissions, :globn2o)
    connectparameter(m, :climateco2cycle, :temp, :climatedynamics, :temp)

    connectparameter(m, :climatesf6cycle, :globsf6, :emissions, :globsf6)

    connectparameter(m, :climateforcing, :acco2, :climateco2cycle, :acco2)
    connectparameter(m, :climateforcing, :acch4, :climatech4cycle, :acch4)
    connectparameter(m, :climateforcing, :acn2o, :climaten2ocycle, :acn2o)
    connectparameter(m, :climateforcing, :acsf6, :climatesf6cycle, :acsf6)

    connectparameter(m, :climatedynamics, :radforc, :climateforcing, :radforc)

    connectparameter(m, :climateregional, :inputtemp, :climatedynamics, :temp)

    connectparameter(m, :biodiversity, :temp, :climatedynamics, :temp)

    connectparameter(m, :ocean, :temp, :climatedynamics, :temp)

    connectparameter(m, :impactagriculture, :population, :population, :population)
    connectparameter(m, :impactagriculture, :income, :socioeconomic, :income)
    connectparameter(m, :impactagriculture, :temp, :climateregional, :temp)
    connectparameter(m, :impactagriculture, :acco2, :climateco2cycle, :acco2)

    connectparameter(m, :impactbiodiversity, :temp, :climateregional, :temp)
    connectparameter(m, :impactbiodiversity, :nospecies, :biodiversity, :nospecies)
    connectparameter(m, :impactbiodiversity, :income, :socioeconomic, :income)
    connectparameter(m, :impactbiodiversity, :population, :population, :population)

    connectparameter(m, :impactcardiovascularrespiratory, :population, :population, :population)
    connectparameter(m, :impactcardiovascularrespiratory, :temp, :climateregional, :temp)
    connectparameter(m, :impactcardiovascularrespiratory, :plus, :socioeconomic, :plus)
    connectparameter(m, :impactcardiovascularrespiratory, :urbpop, :socioeconomic, :urbpop)

    connectparameter(m, :impactcooling, :population, :population, :population)
    connectparameter(m, :impactcooling, :income, :socioeconomic, :income)
    connectparameter(m, :impactcooling, :temp, :climateregional, :temp)
    connectparameter(m, :impactcooling, :cumaeei, :emissions, :cumaeei)

    connectparameter(m, :impactdiarrhoea, :population, :population, :population)
    connectparameter(m, :impactdiarrhoea, :income, :socioeconomic, :income)
    connectparameter(m, :impactdiarrhoea, :regtmp, :climateregional, :regtmp)

    connectparameter(m, :impactextratropicalstorms, :population, :population, :population)
    connectparameter(m, :impactextratropicalstorms, :income, :socioeconomic, :income)
    connectparameter(m, :impactextratropicalstorms, :acco2, :climateco2cycle, :acco2)

    connectparameter(m, :impactforests, :population, :population, :population)
    connectparameter(m, :impactforests, :income, :socioeconomic, :income)
    connectparameter(m, :impactforests, :temp, :climateregional, :temp)
    connectparameter(m, :impactforests, :acco2, :climateco2cycle, :acco2)

    connectparameter(m, :impactheating, :population, :population, :population)
    connectparameter(m, :impactheating, :income, :socioeconomic, :income)
    connectparameter(m, :impactheating, :temp, :climateregional, :temp)
    connectparameter(m, :impactheating, :cumaeei, :emissions, :cumaeei)

    connectparameter(m, :impactvectorbornediseases, :population, :population, :population)
    connectparameter(m, :impactvectorbornediseases, :income, :socioeconomic, :income)
    connectparameter(m, :impactvectorbornediseases, :temp, :climateregional, :temp)

    connectparameter(m, :impacttropicalstorms, :population, :population, :population)
    connectparameter(m, :impacttropicalstorms, :income, :socioeconomic, :income)
    connectparameter(m, :impacttropicalstorms, :regstmp, :climateregional, :regstmp)

    connectparameter(m, :vslvmorb, :population, :population, :population)
    connectparameter(m, :vslvmorb, :income, :socioeconomic, :income)

    connectparameter(m, :impactdeathmorbidity, :vsl, :vslvmorb, :vsl)
    connectparameter(m, :impactdeathmorbidity, :vmorb, :vslvmorb, :vmorb)
    connectparameter(m, :impactdeathmorbidity, :population, :population, :population)
    connectparameter(m, :impactdeathmorbidity, :dengue, :impactvectorbornediseases, :dengue)
    connectparameter(m, :impactdeathmorbidity, :schisto, :impactvectorbornediseases, :schisto)
    connectparameter(m, :impactdeathmorbidity, :malaria, :impactvectorbornediseases, :malaria)
    connectparameter(m, :impactdeathmorbidity, :cardheat, :impactcardiovascularrespiratory, :cardheat)
    connectparameter(m, :impactdeathmorbidity, :cardcold, :impactcardiovascularrespiratory, :cardcold)
    connectparameter(m, :impactdeathmorbidity, :resp, :impactcardiovascularrespiratory, :resp)
    connectparameter(m, :impactdeathmorbidity, :diadead, :impactdiarrhoea, :diadead)
    connectparameter(m, :impactdeathmorbidity, :hurrdead, :impacttropicalstorms, :hurrdead)
    connectparameter(m, :impactdeathmorbidity, :extratropicalstormsdead, :impactextratropicalstorms, :extratropicalstormsdead)
    connectparameter(m, :impactdeathmorbidity, :diasick, :impactdiarrhoea, :diasick)

    connectparameter(m, :impactwaterresources, :population, :population, :population)
    connectparameter(m, :impactwaterresources, :income, :socioeconomic, :income)
    connectparameter(m, :impactwaterresources, :temp, :climateregional, :temp)

    connectparameter(m, :impactsealevelrise, :population, :population, :population)
    connectparameter(m, :impactsealevelrise, :income, :socioeconomic, :income)
    connectparameter(m, :impactsealevelrise, :sea, :ocean, :sea)
    connectparameter(m, :impactsealevelrise, :area, :geography, :area)

    connectparameter(m, :impactaggregation, :income, :socioeconomic, :income)
    connectparameter(m, :impactaggregation, :heating, :impactheating, :heating)
    connectparameter(m, :impactaggregation, :cooling, :impactcooling, :cooling)
    connectparameter(m, :impactaggregation, :agcost, :impactagriculture, :agcost)
    connectparameter(m, :impactaggregation, :species, :impactbiodiversity, :species)
    connectparameter(m, :impactaggregation, :water, :impactwaterresources, :water)
    connectparameter(m, :impactaggregation, :hurrdam, :impacttropicalstorms, :hurrdam)
    connectparameter(m, :impactaggregation, :extratropicalstormsdam, :impactextratropicalstorms, :extratropicalstormsdam)
    connectparameter(m, :impactaggregation, :forests, :impactforests, :forests)
    connectparameter(m, :impactaggregation, :drycost, :impactsealevelrise, :drycost)
    connectparameter(m, :impactaggregation, :protcost, :impactsealevelrise, :protcost)
    connectparameter(m, :impactaggregation, :enterSLRcost, :impactsealevelrise, :enterSLRcost)
    connectparameter(m, :impactaggregation, :deadcost, :impactdeathmorbidity, :deadcost)
    connectparameter(m, :impactaggregation, :morbcost, :impactdeathmorbidity, :morbcost)
    connectparameter(m, :impactaggregation, :wetcost, :impactsealevelrise, :wetcost)
    connectparameter(m, :impactaggregation, :leaveSLRcost, :impactsealevelrise, :leaveSLRcost)

    return m
end

function getfund(;nsteps=1050, datadir=joinpath(dirname(@__FILE__), "..", "data"), params=nothing)
    # ---------------------------------------------
    # Load parameters
    # ---------------------------------------------
    if params==nothing
        parameters = loadparameters(datadir)
    else
        parameters = params
    end

    # ---------------------------------------------
    # Construct model
    # ---------------------------------------------
    m = constructfund(nsteps=nsteps)

    # ---------------------------------------------
    # Load remaining parameters from file
    # ---------------------------------------------
    setleftoverparameters(m, parameters)

    # ---------------------------------------------
    # Return model
    # ---------------------------------------------

    return m
end
