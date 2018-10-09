using Mimi
using CSVFiles, DataFrames

@defcomp migrationdeathrisk begin
    regions = Index()
    iso3c   = Index()

    migdeathrisk  = Variable(index=[regions, regions])
    migrate_flow  = Variable(index=[regions, regions])
    death_journey_fund = Variable(index=[regions, regions])

    origin_fund   = Variable(index=[regions])
    death_fund    = Variable(index=[regions])

    migrant_flows     = Parameter(index=[iso3c, iso3c])
    iso3c_fundregion  = Parameter(index=[iso3c])
end


# Calculating the risk of dying while attempting to migrate across borders: 
# We use data on migration flows between regions in period 2005-2010 from Abel (2013), used in the SSP population scenarios
# And data on missing migrants in period 2014-2018 from IOM (http://missingmigrants.iom.int/). Retrieved on 9/21/2018.

# NOTE: we assume that migrants died in their destination region. E.g. if a Central American dies in Central America on its way to the USA, we attribute it to a CAM-CAM journey.
# The only exception is for migrants dead in the Mediterranean, which we attribute to journeys to WEU.

# death_journey = DataFrame(load("migrant-deaths-by-origin-region.csv"))

origin_regions = ["Europe", "North Africa", "Horn of Africa", "Horn of Africa (P)", "Sub-Saharan Africa", "Middle East", "Middle East and South Asia", "Middle East and South Asia (P)", "Central Asia", "South Asia", "Southeast Asia", "East Asia", "East Asia (P)", "Latin America and the Caribbean (P)", "Caribbean", "Central America", "South America", "Unknown"]
deaths_regions = ["North Africa", "Horn of Africa", "Sub-Saharan Africa", "North America", "US-Mexico border", "Central America", "Caribbean", "South America", "Central Asia", "East Asia", "Southeast Asia", "South Asia", "Europe", "Eastern Mediterranean", "Western + Central Mediterranean", "Middle East"]
missing_migrants = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,21,22,20,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,9,3,6,0,0,0,0,0,0,17,175,82,26,0,0,0,0,0,10,517,1054,151,0,249,135,235,156,0,0,27,66,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,10,5,4,1,0,3,0,1,0,294,6,30,1,1,0,0,1,0,0,0,0,0,119,19,0,0,0,15,123,0,0,0,8,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,46,103,202,42,10,0,0,0,0,0,268,44,24,221,90,0,0,0,1,0,0,0,0,0,0,0,5,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,8,6,0,0,0,23,0,1065,1040,1108,800,226,0,0,1,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,11,6,7,18,335,60,13,19,314,37,7,1,0,0,4,97,90,53,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,71,9,0,4,0,416,284,1,63,0,0,0,0,0,0,2,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,83,0,0,1,0,0,0,21,9,6,9,17,22,6,4,43,46,1,7,1,15,0,1,6,38,20,15,131,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,706,123,294,65,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,291,286,274,289,72,3,31,36,31,18,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,2,2,5,0,0,73,63,80,167,1,0,2,16,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,51,118,105,41,111,56,111,455,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,7,0,0,7,0,1,0,0,5,19,0,18,0,0,1,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,34,182,226,644,23,16,0,0,8,0,0,3,2,304,0,0,0,0,0,0,0,0,3,13,1,0,0,25,11,0,0,0,15,0,0,0,0,15,0,0,0,0,0,0,0,9,15,3,0,0,814,0,64,6,0,1,0,0,0,0,3,27,10,53,15,37,0,44,23,0,1550,1864,3509,2192,1141,0,0,0,0,0]
death_journey = DataFrame(origin = repeat(origin_regions, inner = length(2014:2018) * length(deaths_regions)), 
                                    deathloc = repeat(deaths_regions, inner = length(2014:2018), outer = length(origin_regions)),
                                    year = repeat(2014:2018, outer = length(origin_regions) * length(deaths_regions)),
                                    missing = missing_migrants)

function run_timestep(s::migrationdeathrisk, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Calculating migrant flows at FUND regions level 
    for source in d.regions
        for destination in d.regions
            v.migrate_flow[source, destination] = 0.0
        end
    end
    for origin in d.iso3c
        region_o = p.iso3c_fundregion[origin]
        for dest in d.iso3c
            region_d = p.iso3c_fundregion[dest]
            v.migrate_flow[region_o, region_d] += migrant_flows[origin, dest]
        end
    end

    # Corresponding regions in the data on missing migrants with FUND regions
    # Origin: no category for USA, CAN and ANZ
    v.origin_fund["EEU"] = v.origin_fund["WEU"] = "Europe"
    v.origin_fund["NAF"] = "North Africa"
    v.origin_fund["SSA"] = "Sub-Saharan Africa"
    v.origin_fund["FSU"] = "Central Asia"     # Assume other countries in FSU not in Central Asia are not relevant
    v.origin_fund["MDE"] = "Middle East"
    v.origin_fund["SAS"] = "South Asia"
    v.origin_fund["SEA"] = "Southeast Asia" 
    v.origin_fund["CHI"] = v.origin_fund["JPK"] = "East Asia"
    v.origin_fund["CAM"] = "Central America"
    v.origin_fund["LAM"] = "South America"
    v.origin_fund["SIS"] = "Caribbean"        # Assume migrant deaths of SIS happen in the Caribbean

    # Place of death: no category for CAN and ANZ
    v.death_fund["NAF"] = "North Africa"
    v.death_fund["SSA"] = "Sub-Saharan Africa"
    v.death_fund["USA"] = "North America"     # Based on detailed IOM data, the dead migrant in North America died in the USA
    v.death_fund["CAM"] = "Central America" ; v.death_fund["SIS"] = "Caribbean" ; v.death_fund["LAM"] = "South America"
    v.death_fund["FSU"] = "Central Asia"
    v.death_fund["CHI"] = v.death_fund["JPK"] = "East Asia"
    v.death_fund["SEA"] = "Southeast Asia"
    v.death_fund["SAS"] = "South Asia"
    v.death_fund["WEU"] = v.death_fund["EEU"] = "Europe"
    v.death_fund["MDE"] = "Middle East"
    
    # Sum migrant deaths over the period 2014-2018
    missing_tot = Array(by(death_journey, [:origin, :deathloc], d -> sum(d[:missing])))

    # Convert migrant deaths to FUND regions level (missing_tot into death_journey_fund)
    missing_tot_value = zeros(Int64, length(origin_regions), length(deaths_regions))
    for origin in origin_regions
        for death in deaths_regions
            index_o = findfirst(origin_regions, origin)
            index_d = findfirst(deaths_regions, death)
            index = findfirst([missing_tot[:,1][i] == origin && missing_tot[:,2][i] == death for i in 1:length(missing_tot[:,1])], true)
            missing_tot_value[index_o, index_d] = missing_tot[index, 3]    
        end
    end
  
    for origin in d.regions
        for death in d.regions
            if origin != "USA" && origin != "CAN" && origin != "ANZ" && death != "CAN" && death != "ANZ"
                v.death_journey_fund[origin, death] = missing_tot_value[findfirst(origin_regions, v.origin_fund[origin]), findfirst(deaths_regions, v.death_fund[death])]
            elseif origin == "USA" || origin == "CAN" || origin == "ANZ"
                v.death_journey_fund[origin, death] = 0.0       # No dead migrant originating from North America or Oceania
            elseif death == "CAN" || death == "ANZ"             # No migrant death in Oceania
                v.death_journey_fund[origin, death] = 0.0       # Based on detailed IOM data, the dead migrant in North America died in the USA
            end
        end
    end

    v.death_journey_fund["WEU", "WEU"] = v.death_journey_fund["WEU", "EEU"] = v.death_journey_fund["EEU", "EEU"] = 0.0  # Assume the dead migrant from Europe died on EEU-WEU journey
    v.death_journey_fund["SEA", "JPK"] = v.death_journey_fund["SAS", "JPK"] = 0.0       # Based on detailed IOM data, migrant deaths to East Asia all happened in CHI region
    
    for death in d.regions
        v.death_journey_fund["SSA", death] += missing_tot_value[findfirst(origin_regions, "Horn of Africa"), findfirst(deaths_regions, v.death_fund[death])] + missing_tot_value[findfirst(origin_regions, "Horn of Africa (P)"), findfirst(deaths_regions, v.death_fund[death])]
        v.death_journey_fund["CHI", death] += missing_tot_value[findfirst(origin_regions, "East Asia (P)"), findfirst(deaths_regions, v.death_fund[death])]
        v.death_journey_fund["MDE", death] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, v.dead_fund[death])] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, v.death_fund[death])] / (v.death_journey_fund["MDE", death] + v.death_journey_fund["SAS", death]))
        v.death_journey_fund["SAS", death] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, v.dead_fund[death])] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, v.death_fund[death])] / (v.death_journey_fund["MDE", death] + v.death_journey_fund["SAS", death]))
        v.death_journey_fund["CAM", death] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, v.death_fund[death])] / (v.death_journey_fund["CAM", death] + v.death_journey_fund["LAM", death] + v.death_journey_fund["SIS", death]))
        v.death_journey_fund["LAM", death] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, v.death_fund[death])] / (v.death_journey_fund["CAM", death] + v.death_journey_fund["LAM", death] + v.death_journey_fund["SIS", death]))
        v.death_journey_fund["SIS", death] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, v.death_fund[death])] / (v.death_journey_fund["CAM", death] + v.death_journey_fund["LAM", death] + v.death_journey_fund["SIS", death]))
    end
    # We attribute missing migrants of unknown origin proportionally to origins of known missing migrants in the region
    for death in d.regions
        for origin in d.regions
            v.death_journey_fund[origin, death] *= (1 + missing_tot_value[findfirst(origin_regions, "Unknown"), findfirst(deaths_regions, v.death_fund[death])] / sum(v.death_journey_fund[r, death] for r in d.regions))
        end
    end    

    for origin in d.regions
        v.death_journey_fund[origin, "SSA"] += missing_tot_value[findfirst(origin_regions, v.origin_fund[origin]), findfirst(deaths_regions, "Horn of Africa")]
        v.death_journey_fund[origin, "USA"] += missing_tot_value[findfirst(origin_regions, v.origin_fund[origin]), findfirst(deaths_regions, "US-Mexico border")]  # Assume migrants dead at US-Mexico border were trying to enter the USA
        if origin != "EEU" && origin != "WEU"
            v.death_journey_fund[origin, "WEU"] *= (1 / (1 + v.migrate_flow[origin, "EEU"] / v.migrate_flow[origin, "WEU"]))
            v.death_journey_fund[origin, "EEU"] *= (1 / (1 + v.migrate_flow[origin, "WEU"] / v.migrate_flow[origin, "EEU"]))
        end
        v.death_journey_fund[origin, "EEU"] += missing_tot_value[findfirst(origin_regions, v.origin_fund[origin]), findfirst(deaths_regions, "Eastern Mediterranean")] # Based on IOM data,migrants died in Eastern Mediterranean were generally attempting to enter EEU
        v.death_journey_fund[origin, "WEU"] += missing_tot_value[findfirst(origin_regions, v.origin_fund[origin]), findfirst(deaths_regions, "Western + Central Mediterranean")] # Based on IOM data,migrants died in Western and Central Mediterranean were generally attempting to enter WEU
    end
    
    v.death_journey_fund["SSA", "SSA"] += missing_tot_value[findfirst(origin_regions, "Horn of Africa"), findfirst(deaths_regions, "Horn of Africa")] + missing_tot_value[findfirst(origin_regions, "Horn of Africa (P)"), findfirst(deaths_regions, "Horn of Africa")]
    v.death_journey_fund["CHI", "SSA"] += missing_tot_value[findfirst(origin_regions, "East Asia (P)"), findfirst(deaths_regions, "Horn of Africa")]
    v.death_journey_fund["MDE", "SSA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "Horn of Africa")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "Horn of Africa")] / (v.death_journey_fund["MDE", "SSA"] + v.death_journey_fund["SAS", "SSA"]))
    v.death_journey_fund["SAS", "SSA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "Horn of Africa")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "Horn of Africa")] / (v.death_journey_fund["MDE", "SSA"] + v.death_journey_fund["SAS", "SSA"]))
    v.death_journey_fund["CAM", "SSA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Horn of Africa")] / (v.death_journey_fund["CAM", "SSA"] + v.death_journey_fund["LAM", "SSA"] + v.death_journey_fund["SIS", "SSA"]))
    v.death_journey_fund["LAM", "SSA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Horn of Africa")] / (v.death_journey_fund["CAM", "SSA"] + v.death_journey_fund["LAM", "SSA"] + v.death_journey_fund["SIS", "SSA"]))
    v.death_journey_fund["SIS", "SSA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Horn of Africa")] / (v.death_journey_fund["CAM", "SSA"] + v.death_journey_fund["LAM", "SSA"] + v.death_journey_fund["SIS", "SSA"]))
    for origin in d.regions
        v.death_journey_fund[origin, "SSA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Unknown"), findfirst(deaths_regions, "Horn of Africa")] / sum(v.death_journey_fund[r, "SSA"] for r in d.regions))
    end
    v.death_journey_fund["SSA", "USA"] += missing_tot_value[findfirst(origin_regions, "Horn of Africa"), findfirst(deaths_regions, "US-Mexico border")] + missing_tot_value[findfirst(origin_regions, "Horn of Africa (P)"), findfirst(deaths_regions, "US-Mexico border")]
    v.death_journey_fund["CHI", "USA"] += missing_tot_value[findfirst(origin_regions, "East Asia (P)"), findfirst(deaths_regions, "US-Mexico border")]
    v.death_journey_fund["MDE", "USA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "US-Mexico border")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "US-Mexico border")] / (v.death_journey_fund["MDE", "USA"] + v.death_journey_fund["SAS", "USA"]))
    v.death_journey_fund["SAS", "USA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "US-Mexico border")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "US-Mexico border")] / (v.death_journey_fund["MDE", "USA"] + v.death_journey_fund["SAS", "USA"]))
    v.death_journey_fund["CAM", "USA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "US-Mexico border")] / (v.death_journey_fund["CAM", "USA"] + v.death_journey_fund["LAM", "USA"] + v.death_journey_fund["SIS", "USA"]))
    v.death_journey_fund["LAM", "USA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "US-Mexico border")] / (v.death_journey_fund["CAM", "USA"] + v.death_journey_fund["LAM", "USA"] + v.death_journey_fund["SIS", "USA"]))
    v.death_journey_fund["SIS", "USA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "US-Mexico border")] / (v.death_journey_fund["CAM", "USA"] + v.death_journey_fund["LAM", "USA"] + v.death_journey_fund["SIS", "USA"]))
    for origin in d.regions
        v.death_journey_fund[origin, "USA"] *= (1 + missing_tot_value[findfirst(origin_regions, "Unknown"), findfirst(deaths_regions, "US-Mexico border")] / sum(v.death_journey_fund[r, "USA"] for r in d.regions))
    end
    v.death_journey_fund["SSA", "EEU"] += missing_tot_value[findfirst(origin_regions, "Horn of Africa"), findfirst(deaths_regions, "Eastern Mediterranean")] + missing_tot_value[findfirst(origin_regions, "Horn of Africa (P)"), findfirst(deaths_regions, "Eastern Mediterranean")]
    v.death_journey_fund["CHI", "EEU"] += missing_tot_value[findfirst(origin_regions, "East Asia (P)"), findfirst(deaths_regions, "Eastern Mediterranean")]
    v.death_journey_fund["MDE", "EEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "Eastern Mediterranean")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "Eastern Mediterranean")] / (v.death_journey_fund["MDE", "EEU"] + v.death_journey_fund["SAS", "EEU"]))
    v.death_journey_fund["SAS", "EEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "Eastern Mediterranean")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "Eastern Mediterranean")] / (v.death_journey_fund["MDE", "EEU"] + v.death_journey_fund["SAS", "EEU"]))
    v.death_journey_fund["CAM", "EEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Eastern Mediterranean")] / (v.death_journey_fund["CAM", "EEU"] + v.death_journey_fund["LAM", "EEU"] + v.death_journey_fund["SIS", "EEU"]))
    v.death_journey_fund["LAM", "EEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Eastern Mediterranean")] / (v.death_journey_fund["CAM", "EEU"] + v.death_journey_fund["LAM", "EEU"] + v.death_journey_fund["SIS", "EEU"]))
    v.death_journey_fund["SIS", "EEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Eastern Mediterranean")] / (v.death_journey_fund["CAM", "EEU"] + v.death_journey_fund["LAM", "EEU"] + v.death_journey_fund["SIS", "EEU"]))
    for origin in d.regions
        v.death_journey_fund[origin, "EEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Unknown"), findfirst(deaths_regions, "Eastern Mediterranean")] / sum(v.death_journey_fund[r, "EEU"] for r in d.regions))
    end
    v.death_journey_fund["SSA", "WEU"] += missing_tot_value[findfirst(origin_regions, "Horn of Africa"), findfirst(deaths_regions, "Western + Central Mediterranean")] + missing_tot_value[findfirst(origin_regions, "Horn of Africa (P)"), findfirst(deaths_regions, "Western + Central Mediterranean")]
    v.death_journey_fund["CHI", "WEU"] += missing_tot_value[findfirst(origin_regions, "East Asia (P)"), findfirst(deaths_regions, "Western + Central Mediterranean")]
    v.death_journey_fund["MDE", "WEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "Western + Central Mediterranean")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "Western + Central Mediterranean")] / (v.death_journey_fund["MDE", "WEU"] + v.death_journey_fund["SAS", "WEU"]))
    v.death_journey_fund["SAS", "WEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia"), findfirst(deaths_regions, "Western + Central Mediterranean")] + missing_tot_value[findfirst(origin_regions, "Middle East and South Asia (P)"), findfirst(deaths_regions, "Western + Central Mediterranean")] / (v.death_journey_fund["MDE", "WEU"] + v.death_journey_fund["SAS", "WEU"]))
    v.death_journey_fund["CAM", "WEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Western + Central Mediterranean")] / (v.death_journey_fund["CAM", "WEU"] + v.death_journey_fund["LAM", "WEU"] + v.death_journey_fund["SIS", "WEU"]))
    v.death_journey_fund["LAM", "WEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Western + Central Mediterranean")] / (v.death_journey_fund["CAM", "WEU"] + v.death_journey_fund["LAM", "WEU"] + v.death_journey_fund["SIS", "WEU"]))
    v.death_journey_fund["SIS", "WEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Latin America and the Caribbean (P)"), findfirst(deaths_regions, "Western + Central Mediterranean")] / (v.death_journey_fund["CAM", "WEU"] + v.death_journey_fund["LAM", "WEU"] + v.death_journey_fund["SIS", "WEU"]))
    for origin in d.regions
        v.death_journey_fund[origin, "WEU"] *= (1 + missing_tot_value[findfirst(origin_regions, "Unknown"), findfirst(deaths_regions, "Western + Central Mediterranean")] / sum(v.death_journey_fund[r, "WEU"] for r in d.regions))
    end

    # Calculating the risk of dying on a journey as the ratio of missing migrants and migrants flows on that journey
    for source in d.regions
        for destination in d.regions
            v.migdeathrisk[source, destination] = v.death_journey_fund[source, destination] / v.migrate_flow[source, destination]
        end
    end
end