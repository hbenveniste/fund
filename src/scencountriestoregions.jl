using Mimi

@defcomp scencountriestoregions begin
    regions = Index()
    isonum  = Index()
    iso2c   = Index()

    lifeexp       = Variable(index=[time, regions])
    distance      = Variable(index=[regions, regions])
    pop2010weight = Variable(index=[regions])
    long_region   = Variable(index=[regions])
    lat_region    = Variable(index=[regions])

    scenlifeexp       = Parameter(index=[time, isonum])
    scenlifeexphist   = Parameter(index=[time, isonum])
    pop2010           = Parameter(index=[isonum])
    isonum_fundregion = Parameter(index=[isonum])
    iso2c_fundregion  = Parameter(index=[iso2c])
    iso2c_isonum      = Parameter(index=[iso2c])
    long_country      = Parameter(index=[iso2c])
    lat_country       = Parameter(index=[iso2c])
    earth_radius      = Parameter()
end

function run_timestep(s::scencountriestoregions, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Initializing variables 
    for r in d.regions
        v.pop2010weight[r] = 0.0
        v.lifeexp[t, r] = 0.0
        v.long_region[r] = 0.0
        v.lat_region[r] = 0.0
    end

    # Calculating population weights based on country level population data in 2010 from Wittgenstein Centre
    for country in d.isonum
        region = p.isonum_fundregion[country]
        v.pop2010weight[region] += p.pop2010[country]
    end

    # Calculating life expectancy scenarios at region level
    # Data on SSP scenarios life expectancy is available from Wittgenstein Centre for 1970-2100 
    # We use data from UN World Population Prospects 2017 for 1950-1970
    # We assume constant life expectancy after 2100

    year = t + 1949

    if year < 2100                                                                   
        for country in d.isonum                                                         # linearizing life expectancy data from 5-year averages to yearly values at country level
            if year < 1953
                ind = (year - mod(year, 5) - 1950) / 5 + 1                              # defining time index for data available every 5 years starting 1950
                floor = p.scenlifeexphist[ind, country] ; ceiling = p.scenlifeexphist[ind + 1, country]
                lifeexpcountry = floor + (ceiling - floor) / 5 * (mod(year, 5) - 2.5)
            elseif year < 1968
                ind = (year - 2.5 - mod(year - 2.5, 5) - 1950) / 5 + 1               
                floor = p.scenlifeexphist[ind, country] ; ceiling = p.scenlifeexphist[ind + 1, country]
                lifeexpcountry = floor + (ceiling - floor) / 5 * (mod(year, 5) + 2.5) 
            elseif year < 1970
                ind = (year - mod(year, 5) - 1950) / 5 + 1
                floor = p.scenlifeexphist[ind, country] ; subfloor = p.scenlifeexphist[ind - 1, country]
                lifeexpcountry = subfloor + (floor - subfloor) / 5 * (mod(year, 5) + 2.5)
            elseif year < 1973
                ind = (year - mod(year, 5) - 1970) / 5 + 1                              # defining time index for data available every 5 years starting 1970
                floor = p.scenlifeexp[ind, country] ; ceiling = p.scenlifeexp[ind + 1, country]
                lifeexpcountry = floor + (ceiling - floor) / 5 * (mod(year, 5) - 2.5)
            elseif year < 2095                                                       
                ind = (year - 2.5 - mod(year - 2.5, 5) - 1970) / 5 + 1               
                floor = p.scenlifeexp[ind, country] ; ceiling = p.scenlifeexp[ind + 1, country]
                lifeexpcountry = floor + (ceiling - floor) / 5 * (mod(year, 5) + 2.5)         
            else
                ind = (year - mod(year, 5) - 1970) / 5 + 1
                floor = p.scenlifeexp[ind, country] ; subfloor = p.scenlifeexp[ind - 1, country]
                lifeexpcountry = subfloor + (floor - subfloor) / 5 * (mod(year, 5) + 2.5)
            end
            region = p.isonum_fundregion[country]                                       # averaging with population weights at region level
            v.lifeexp[t, region] += lifeexpcountry * p.pop2010[country]
        end
        for r in d.regions
            v.lifeexp[t, r] /= v.pop2010weight[r]
        end
    else year >= 2100
        for r in d.regions
            v.lifeexp[t, r] = v.lifeexp[150, r]                                        
        end
    end

    # Calculating distances between regions as distances between centers of population of regions
    # Centers of population of regions are computed as the aryhtmetic means of coordinates of a region's countries weighted by 2010 country-level population
    # Distances between two centers of population are computed as great-circle distances based on the haversine formula (e.g. used in NASA's distance calculator (https://www.nhc.noaa.gov/gccalc.shtml))
    # Distances are expressed in km

    for country in d.iso2c
        region = p.iso2c_fundregion[country]
        v.long_region[region] += p.long_country[country] * p.pop2010[p.iso2c_isonum[country]]
        v.lat_region[region] += p.lat_country[country] * p.pop2010[p.iso2c_isonum[country]]
    end
    for r in d.regions
        v.long_region[r] /= v.pop2010weight[r]
        v.lat_region[r] /= v.pop2010weight[r]
    end
    for r1 in d.regions
        for r2 in d.regions
            lat1 = v.lat_region[r1] * pi / 180                                          # converting degrees to radian
            lat2 = v.lat_region[r2] * pi / 180 
            lon1 = v.long_region[r1] * pi / 180 
            lon2 = v.long_region[r2] * pi / 180
            v.distance[r1, r2] = p.earth_radius * 2 * asin(sqrt((sin((lat1 - lat2) / 2))^2 + cos(lat1) * cos(lat2) * (sin((lon1 - lon2) / 2))^2))       # haversine formula
        end
    end
end