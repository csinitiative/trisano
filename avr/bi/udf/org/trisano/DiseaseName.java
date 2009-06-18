package org.trisano;

import mondrian.olap.*;
import mondrian.olap.type.*;
import mondrian.spi.UserDefinedFunction;
import org.apache.log4j.Logger;
import java.sql.*;

public class DiseaseName implements UserDefinedFunction {
    private static final Logger logger = Logger.getLogger(DiseaseName.class);

    public DiseaseName() { }

    public String getName() { return "DiseaseName"; }

    public String getDescription() {
        return "Returns the disease name for the current context";
    }
    
    public Syntax getSyntax() { return Syntax.Function; }

    public Type getReturnType(Type[] parameterTypes) {
        return new NumericType();
    }

    public Type[] getParameterTypes() {
        return new Type[] { new NumericType() };
    }

    public Object execute(Evaluator evaluator, UserDefinedFunction.Argument[] arguments) {
        logger.info("Running diseasename function");
        try {
            Statement st;
            ResultSet rs;

            java.sql.Connection conn =
                evaluator.getQuery().getConnection().getDataSource().getConnection();
            st = conn.createStatement();
            if (st.execute("SELECT now()")) {
                rs = st.getResultSet();
                rs.next();
                logger.info("NOW() returned \"" + rs.getString(1) + "\"");
            }
            else
                logger.info("SELECT now() didn't return anything, somehow");
            conn.close();
        }
        catch (SQLException s) {
            logger.warn("JDBC Error: " + s);
        }

        for (Dimension d : evaluator.getCube().getDimensions()) {
            if (d.getName().equals("Disease"))
                return evaluator.getContext(d).getLevel().getDepth();
        }
        return null;
    }

    public String[] getReservedWords() { return null; }
}
