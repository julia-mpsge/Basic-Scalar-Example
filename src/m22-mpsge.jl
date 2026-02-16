using MPSGE

function mpsge_model()

    M = MPSGEModel()

    @parameters(M, begin
        TX_PL, 0, (description = "Ad valorem tax on sector X good PL")
        TX_PK, 0, (description = "Ad valorem tax on sector X good PK")
    end)

    @sectors(M, begin
        X, (description = "Activity level for sector X")
        Y, (description = "Activity level for sector Y")
        W, (description = "Activity level for sector W (Hicksian welfare index)")
    end)

    @commodities(M, begin
        PX, (description = "Price index for commodity X")
        PY, (description = "Price index for commodity Y")
        PL, (description = "Price index for primary factor L")
        PK, (description = "Price index for primary factor K", start = 1)
        PW, (description = "Price index for welfare (expenditure function)")
    end)

    @consumer(M, CONS, description = "Income level for consumer CONS")

    @production(M, X, [t=0, s=0.5, va => s = 1], begin
        @output(PX, 120, t)
        @input(PY, 20, s)
        @input(PL, 40, va, taxes = [Tax(CONS, TX_PL)])
        @input(PK, 60, va, taxes = [Tax(CONS, TX_PK)])
    end)

    @production(M, Y, [t=0, s=0.75, va=>s=1], begin
        @output(PY, 120, t)
        @input(PX, 20, s)
        @input(PL, 60, va)
        @input(PK, 40, va)
    end)

    @production(M, W, [t=0, s=1], begin
        @output(PW, 200, t)
        @input(PX, 100, s)
        @input(PY, 100, s)
    end)

    @demand(M, CONS, begin
        @final_demand(PW, 200)
        @endowment(PL, 100)
        @endowment(PK, 100)
    end)

    return M
end

M = mpsge_model()

# Benchmark

fix(M[:PW], 1)
solve!(M, cumulative_iteration_limit=0)


# Counterfactual

set_value!(M[:TX_PL], .8)
set_value!(M[:TX_PK], .5)
solve!(M)

value(M[:X])