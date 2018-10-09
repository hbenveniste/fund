using ExcelReaders
using DataFrames
using RDatasets

datagdpname = normpath(Pkg.dir("hmrb/FUND-the-project/fund.jl"),"ssp", "SSP_gdp_oecd.xlsx") #--potentially need to change file names in the data directory
datagdp = openxl(datagdpname)
datapopname = normpath(Pkg.dir("fund.jl"),"ssp", "SSP_pop.xlsx") #--potentially need to change file names in the data directory
datapop = openxl(datapopname)

dfy = readxlsheet(DataFrame, datagdp, "data") #--potentially need to change tab names
dfp = readxlsheet(DataFrame, datapop, "data") #--potentially need to change tab names

fundregions = ["USA", "CAN", "WEU", "JPK", "ANZ", "EEU", "FSU", "MDE", "CAM", "LAM", "SAS", "SEA", "CHI", "NAF", "SSA", "SIS"]
fundcountries = Dict("USA" => ["USA"],
                     "CAN" => ["CAN"],
                     "WEU" => ["AUT","BEL","CYP","DNK","FIN","FRA","DEU","GRC","ISL","IRL","ITA","LUX","MLT","NLD","NOR","PRT","ESP","SWE","CHE","GBR"], #--Missing: Andorra, Liechtenstein, Monaco, San Marino
                     "JPK" => ["JPN","KOR"],
                     "ANZ" => ["AUS","NZL"],
                     "EEU" => ["ALB","BIH","BGR","HRV","CZE","HUN","MKD","POL","ROU","SRB","SVK","SVN"], #--adding Serbia and Montenegro, not in the FUND description
                     "FSU" => ["ARM","AZE","BLR","EST","GEO","KAZ","KGZ","LVA","LTU","MDA","RUS","TJK","TKM","UKR","UZB"],
                     "MDE" => ["BHR","IRN","IRQ","ISR","JOR","KWT","LBN","OMN","PSE","QAT","SAU","SYR","TUR","DZA","YEM"], #--Replacing West Bank and Gaza by Palestinian Territories
                     "CAM" => ["BLZ","CRI","SLV","GTM","HND","MEX","NIC","PAN"],
                     "LAM" => ["ARG","BOL","BRA","CHL","COL","ECU","GUY","PRY","PER","SUR","URY","VEN"], #--Missing: French Guyana
                     "SAS" => ["AFG","BGD","BTN","IND","NPL","PAK","LKA"],
                     "SEA" => ["BRN","KHM","TLS","IDN","LAO","MYS","MMR","PNG","PHL","SGP","THA","VNM"], #--Missing: Taiwan
                     "CHI" => ["CHN","HKG","MAC","MNG","PRK"], #--Missing in GDP data: Hong Kong, Macau, North Korea
                     "NAF" => ["ARE","EGY","LBY","MAR","TUN"], #--Missing: Western Sahara
                     "SSA" => ["AGO","BEN","BWA","BFA","BDI","CMR","CPV","CAF","TCD","COD","COG","CIV","DJI","GNQ","ERI","ETH","GAB","GMB","GHA","GIN","GNB","KEN","LSO","LBR","MDG","MWI","MLI","MRT","MOZ","NAM","NER","NGA","RWA","SEN","SLE","SOM","ZAF","SDN","SWZ","TZA","TGO","UGA","ZMB","ZWE"],
                     "SIS" => ["BHS","BRB","COM","CUB","DOM","FJI","GLP","GUM","HTI","JAM","MDV","MTQ","MUS","NCL","PRI","PYF","REU","WSM","SLB","TTO","VUT"]) #--Missing in both: Antigua and Barbuda, Aruba, Bermuda, Dominica, Grenada, Kiribati, Marshall Islands, Micronesia, Nauru, Netherlands Antilles, Palau, Sao Tome and Principe, Seychelles, St Kitts and Nevis, St Lucia, St Vincent and Grenadines, Tonga, Tuvalu, Virgin Islands. Missing in GDP data: Guadeloupe, Martinique, New Caledonia, Puerto Rico, French Polynesia, Reunion. Adding Guam

years = [n for n in 2010:10:2100] #--We do not consider 2005 because no population data for that year

SSP_numbers = [i for i in 1:5]

for i in SSP_numbers 
    #--Separate the 5 SSP scenarios
    dfy_i = dfy[dfy[:Scenario] .== "SSP"*i*"_v9_130325", :] 
    dfp_i = dfp[dfp[:Scenario] .== "SSP"*i*"_v9_130219", :]

    #--Remove unnecessary columns in the datasets
    dfy_i = dfy_i[:, [:Region, :2010, :2020, :2030, :2040, :2050, :2060, :2070, :2080, :2090, :2100]] 
    dfp_i = dfp_i[:, [:Region, :2010, :2020, :2030, :2040, :2050, :2060, :2070, :2080, :2090, :2100]]  

    #--Sum at the FUND region level
    regionlist_y = []
    for country in dfy_i[:Region]
        for region in fundregions
            if country in fundcountries[region]
                push!(regionlist_y, region)
            end
        end
    end
    dfy_i[:FundRegion] = regionlist_y
    dfy_ia = aggregate(dfy_i, :FundRegion, sum) #--don't know how to custom sort following FUND region order

    regionlist_p = []
    for country in dfp_i[:Region]
        for region in fundregions
            if country in fundcountries[region]
                push!(regionlist_p, region)
            end
        end
    end
    dfp_i[:FundRegion] = regionlist_p
    dfp_ia = aggregate(dfp_i, :FundRegion, sum) #--don't know how to custom sort following FUND region order

    #--Calculate per capita GDP with population data
    for j in 1:length(years)
        dfy_ia[names(dfy_ia)[j+1]] = dfy_ia[names(dfy_ia)[j+1]] ./ dfp_ia[names(dfp_ia)[j+1]]
    end

    #--Linear interpolation of GDP and population levels
    dfy_l = DataFrame(Year = Int64[], Region = String[], ypc = Float64[])
    dfp_l = DataFrame(Year = Int64[], Region = String[], p = Float64[])
    for j in 1:length(years)
        for region in fundregions
            for r in 1:length(dfy_ia[:FundRegion])
                if dfy_ia[:FundRegion][r] == region
                    push!(dfy_l, [years[j]  region  dfy_ia[names(dfy_ia)[j+1]][r]]) 
                end
                if dfp_ia[:FundRegion][r] == region
                    push!(dfp_l, [years[j]  region  dfp_ia[names(dfp_ia)[j+1]][r]]) 
                end
            end
        end
        if years[j] != 2100
            k = years[j] + 1
            while k < years[j+1]
                for region in fundregions
                    for r in 1:length(dfy_ia[:FundRegion])
                        if dfy_ia[:FundRegion][r] == region
                            valy = dfy_ia[names(dfy_ia)[j+1]][r] + (k-years[j])/(years[j+1]-years[j])*(dfy_ia[names(dfy_ia)[j+2]][r]-dfy_ia[names(dfy_ia)[j+1]][r])
                        end
                        if dfp_ia[:FundRegion][r] == region
                            valp = dfp_ia[names(dfp_ia)[j+1]][r] + (k-years[j])/(years[j+1]-years[j])*(dfp_ia[names(dfp_ia)[j+2]][r]-dfp_ia[names(dfp_ia)[j+1]][r])
                        end
                    end
                    push!(dfy_l, [k  region  valy])
                    push!(dfp_l, [k  region  valp])
               end
               k += 1
            end
        end
    end

    #--Calculate GDP and population growth
    dfy_lgrowth = DataFrame()
    dfp_lgrowth = DataFrame()
    dfy_lgrowth[:Year] = dfy_l[:Year]
    dfp_lgrowth[:Year] = dfp_l[:Year]
    dfy_lgrowth[:Region] = dfy_l[:Region]
    dfp_lgrowth[:Region] = dfp_l[:Region]
    ypcgrowth = []
    pgrowth = []
    for n in 1:(length(dfy_l[:ypc])-1)
        ratey = dfy_l[:ypc][n+1] / dfy_l[:ypc][n] - 1
        ratep = dfp_l[:p][n+1] / dfp_l[:p][n] - 1
        push!(ypcgrowth, ratey)
        push!(pgrowth, ratep)
    end
    push!(ypcgrowth, NA) #-- can we add a missing value?
    push!(pgrowth, NA)
    dfy_lgrowth[:ypcgrowth] = ypcgrowth
    dfp_lgrowth[:pgrowth] = pgrowth

    #--Write csv files for each SSP population and GDP scenario
    writetable("scenypcgrowth_"*dfy[:Model][1]*"_ssp"*string(i)*".csv", dfy_lgrowth, header=false)
    writetable("scenpgrowth_"*dfp[:Model][1]*"_ssp"*string(i)*".csv", dfp_lgrowth, header=false)
end