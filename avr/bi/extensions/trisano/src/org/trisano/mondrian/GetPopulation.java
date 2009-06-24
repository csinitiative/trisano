package org.trisano.mondrian;

import mondrian.olap.*;
import mondrian.olap.type.*;
import mondrian.spi.UserDefinedFunction;
import org.apache.log4j.Logger;
import java.sql.*;
import java.util.ArrayList;

public class GetPopulation implements UserDefinedFunction {
    private static final Logger logger = Logger.getLogger(GetPopulation.class);

    public GetPopulation() { }

    public String getName() { return "GetPopulation"; }

    public String getDescription() {
        return "Returns the population for the current context";
    }

    public Syntax getSyntax() { return Syntax.Function; }

    public Type getReturnType(Type[] parameterTypes) {
        return new NumericType();
    }

    public Type[] getParameterTypes() {
        return new Type[] { new NumericType() };
    }

    public Object execute(Evaluator evaluator, UserDefinedFunction.Argument[] arguments) {
        // Find the current level for dimensions that we care about for
        // population statistics, and calculate the total population given
        // those dimensions. Right now those dimensions are:
        // * Disease
        // * Investigating Jurisdiction
        //
        // Eventually this should probably implement some method to:
        // 1) Not hard code which dimensions are meaningful
        // 2) Handle multi-level dimensions
        // 3) Handle dimensions where Mondrian's value for the dimension
        //    differs from the population table's value
        // TODO: test all this
        ArrayList<String> vals = new ArrayList<String>();
        Object arg = arguments[0].evaluateScalar(evaluator);
        double population = 0;

        if (!(arg instanceof Number))
            return null;

        try {
            PreparedStatement st;
            ResultSet rs;
            String where = "", query;
            int i;

            java.sql.Connection conn =
                evaluator.getQuery().getConnection().getDataSource().getConnection();
            st = conn.prepareStatement("SELECT dim_cols[?], mapping_func FROM population.population_dimensions WHERE dim_name = ?");
            for (Dimension d : evaluator.getCube().getDimensions()) {
                String colname, colmapper;
                Integer depth;

                depth = evaluator.getContext(d).getLevel().getDepth();
                if (depth != 0) {
                    st.setInt(1, depth); st.setString(2, d.getName());
                    rs = st.executeQuery();
                    if (rs.next()) {
                        // rs.next() is true only if it returned something, or in
                        // other words, only when this dimension is important to us
                        colname = rs.getString(1);
                        colmapper = rs.getString(2);
                        logger.debug("Found a meaningful dimension: " + d.getName() + " with colname " + colname + ", depth " + depth + ", and mapping func " + colmapper);

                        if (!where.equals(""))
                            where += " AND ";
                        where += colname + " = ";

                        if (colmapper != null)
                            where += colmapper + "(?)";
                        else
                            where += "?";
                        vals.add(evaluator.getContext(d).getName());
                    }
                }
            }
            query = "SELECT sum(population) FROM population.population" +
                (!where.equals("") ? " WHERE " + where : "");
            logger.debug("Issuing query \"" + query + "\"");

            st = conn.prepareStatement(query);
            i = 0;
            for (String s : vals) {
                i++;
                st.setString(i, s);
            }
            rs = st.executeQuery();
            if (rs.next())
                population = rs.getDouble(1);
            conn.close();
        }
        catch (SQLException s) {
            logger.warn("JDBC Error: " + s);
        }

        if (population == 0)
            return null;
        else
            return population;
    }

    public String[] getReservedWords() { return null; }
}
