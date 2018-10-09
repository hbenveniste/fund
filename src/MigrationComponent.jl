using Mimi

@defcomp migration begin
    regions       = Index()

    move          = Variable(index=[time,regions,regions])
    migstock      = Variable(index=[time,regions,regions])
    enter         = Variable(index=[time,regions])
    leave         = Variable(index=[time,regions])
    migdead       = Variable(index=[time,regions])
    migdeadcost   = Variable(index=[time,regions])
    remittances   = Variable(index=[time,regions])
    migrationcost = Variable(index=[time,regions])

    population    = Parameter(index=[time,regions])
    income        = Parameter(index=[time,regions])
    vsl           = Parameter(index=[time,regions])
    lifeexp       = Parameter(index=[time,regions])

    distance      = Parameter(index=[regions, regions])
    migdeathrisk  = Parameter(index=[regions,regions])

    migmeanage  = Parameter(index=[time])

    alpha         = Parameter()
    migcost       = Parameter()
    remshare      = Parameter()
    remcost       = Parameter()   
end

function run_timestep(s::migration, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if t==1
        for r in d.regions
            for r1 in d.regions
                v.move[t, r, r1] = 0.0
                v.migstock[t, r, r1] = 0
            end
            v.enter[t, r] = 0.0
            v.leave[t, r] = 0.0
            v.migdead[t, r] = 0
            v.migdeadcost[t, r] = 0.0
            v.remittances[t, r] = 0.0
            v.migrationcost[t, r] = 0.0
        end
    else
        # Calculating the number of people migrating from one region to another, based on a gravity model including per capita income.
        # Population and move are expressed in millions, distance in km.
        for destination in d.regions
            ypc_dest = p.income[t, destination] / p.population[t, destination] * 1000.0
            for source in d.regions
                ypc_source = p.income[t, source] / p.population[t, source] * 1000.0
                if ypc_dest > ypc_source
                    move = alpha * p.population[t, source] * p.population[t, destination] / p.distance[source, destination] * ypc_dest / ypc_source
                else
                    move = 0.0
                end
                v.move[t, source, destination] = move
            end
        end

        for destination in d.regions
            enter = 0.0
            for source in d.regions
                enter += v.move[t, source, destination]
            end
            v.enter[t, destination] = enter
        end

        for source in d.regions
            leave = 0.0
            for destination in d.regions
                leave += v.move[t, source, destination]
            end
            v.leave[t, source] = leave
        end

        # Calculating the risk of dying while attempting to migrate across borders: 
        # We use data on migration flows between regions in period 2005-2010 from Abel [2013], used in the SSP population scenarios
        # And data on missing migrants in period 2014-2018 from IOM (http://missingmigrants.iom.int/)
        for r in d.regions
            v.migdead[t, r] = 0.0               # consider risk of dying based on origin region
            for destination in d.regions
                v.migdead[t, r] += p.migdeathrisk[r, destination] * v.move[t, r, destination]
            end
            v.migdeadcost[t, r] = p.vsl[t, r] * v.migdead[t, r] / 1000000000.0
        end

        # Adding a stock variable indicating how many immigrants from a region are in another region.
        # Mean age of migrants at time of migration is based on data from the Mexican Migration Project on Mexico-US migration for 1906-2016. We extrapolate linearly until 2100, thean keep the mean age constant until 2300.
        for source in d.regions
            for destination in d.regions
                v.migstock[t, source, destination] = v.migstock[t - 1, source, destination] + v.move[t, source, destination] - v.migdead[t, source] * v.move[t, source, destination] / v.leave[t, source]
                if t > p.lifeexp[t, destination] - p.migmeanage[t]
                    v.migstock[t, source, destination] -= v.enter[t - (p.lifeexp[t, destination] - p.migmeanage[t]), destination]
                end
            end
        end

        # Calculating remittances sent by migrants in richer regions to their origin communities.
        for r in d.regions
            received = 0.0
            sent = 0.0
            ypc = p.income[t, r] / p.population[t, r] * 1000.0
            for r1 in d.regions
                ypc_r1 = p.income[t, r1] / p.population[t, r1] * 1000.0
                received += v.migstock[t, r, r1] * p.remshare * (1.0 - p.remcost) * ypc_r1 / 1000000000
                sent += v.migstock[t, r1, r] * p.remshare * (1.0 - p.remcost) * ypc / 1000000000
            end
            v.remittances[t, r] = received - sent
        end

        # Calculating aggregated costs of migrating. 
        for r in d.regions
            ypc = p.income[t, r] / p.population[t, r] * 1000.0
            v.migrationcost[t, r] = p.migcost * ypc * v.leave[t, r] / 1000000000
        end
    end
end