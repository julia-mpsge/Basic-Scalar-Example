import JuMP
import PATHSolver

function mcp_model()

    MCP = JuMP.Model(PATHSolver.Optimizer)

    JuMP.@variables(MCP, begin
        TX_PL in JuMP.Parameter(0)
        TX_PK in JuMP.Parameter(0)
    end)

    JuMP.@variables(MCP, begin
        X>=0, (start = 1)
        Y>=0, (start = 1)
        W>=0, (start = 1)
        PX>=0, (start = 1)
        PY>=0, (start = 1)
        PL>=0, (start = 1)
        PK>=0, (start = 1)
        PW>=0, (start = 1)
        CONS>=0, (start = 200)
    end)

    # Zero Profit

    ## X Block 

    ### VA Nest
    cost_X_va_PL = PL * (1 + TX_PL)
    cost_X_va_PK = PK * (1 + TX_PK)
    cost_X_va = cost_X_va_PL^(40/100) * cost_X_va_PK^(60/100)

    cost_X_PY = PY

    cost_X = (20/120*cost_X_PY^(1-.5) + 100/120*cost_X_va^(1-.5))^(1/(1-.5))

    revenue_X = PX

    profit_X = 120*revenue_X - 120*cost_X

    JuMP.@constraint(MCP, zero_profit_X, -profit_X ⟂ X)

    ## Y Block

    ### VA Nest
    cost_Y_va_PL = PL
    cost_Y_va_PK = PK
    cost_Y_va = cost_Y_va_PL^(60/100) * cost_Y_va_PK^(40/100)

    cost_Y_PX = PX

    cost_Y = (20/120*cost_Y_PX^(1-.75) + 100/120*cost_Y_va^(1-.75))^(1/(1-.75))

    revenue_Y = PY
    profit_Y = 120*revenue_Y - 120*cost_Y

    JuMP.@constraint(MCP, zero_profit_Y, -profit_Y ⟂ Y)

    ## W Block

    cost_W_PX = PX
    cost_W_PY = PY

    cost_W = cost_W_PX^(100/200) * cost_W_PY^(100/200)

    revenue_W = PW
    profit_W  = 200*revenue_W - 200*cost_W


    JuMP.@constraint(MCP, zero_profit_W, -profit_W ⟂ W)


    # Market Clearance

    ## PX

    market_PX = 120*X - 20*Y*(cost_Y/cost_Y_PX)^.75 - 100*W*(cost_W/cost_W_PX)^1
    JuMP.@constraint(MCP, clearance_PX, market_PX ⟂ PX)

    ## PY

    market_PY = 120*Y - 20*X*(cost_X/cost_X_PY)^.5 - 100*W*(cost_W/cost_W_PY)^1
    JuMP.@constraint(MCP, clearance_PY, market_PY ⟂ PY)

    ## PL

    market_PL = -40*X*(cost_X/cost_X_va)^.5*(cost_X_va/cost_X_va_PL) - 60*Y*(cost_Y/cost_Y_va)^.75*(cost_Y_va/cost_Y_va_PL) + 100
    JuMP.@constraint(MCP, clearance_PL, market_PL ⟂ PL)

    ## PK

    market_PK = -60*X*(cost_X/cost_X_va)^.5*(cost_X_va/cost_X_va_PK) - 40*Y*(cost_Y/cost_Y_va)^.75*(cost_Y_va/cost_Y_va_PK) + 100
    JuMP.@constraint(MCP, clearance_PK, market_PK ⟂ PK)

    ## PW

    market_PW = 200*W - CONS/PW
    JuMP.@constraint(MCP, clearance_PW, market_PW ⟂ PW)

    # Income Balance

    tax_X_PL = 40*TX_PL*X*PL*(cost_X/cost_X_va)^.5*(cost_X_va/cost_X_va_PL)
    tax_X_PK = 60*TX_PK*X*PK*(cost_X/cost_X_va)^.5*(cost_X_va/cost_X_va_PK)


    income = 100*PL + 100*PK + tax_X_PL + tax_X_PK
    JuMP.@constraint(MCP, income_balance, CONS - income ⟂ CONS)

    return MCP
end


MCP = mcp_model()

## Benchmark

JuMP.fix(MCP[:PW], 1.0; force = true)


JuMP.set_attribute(MCP, "cumulative_iteration_limit", 0)
JuMP.optimize!(MCP)


# Counterfactual

JuMP.set_parameter_value(MCP[:TX_PL], 0.8)
JuMP.set_parameter_value(MCP[:TX_PK], 0.5)
JuMP.set_attribute(MCP, "cumulative_iteration_limit", 10_000)
JuMP.optimize!(MCP)


value(MCP[:X])