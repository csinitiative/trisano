package org.trisano;

import mondrian.olap.*;
import mondrian.olap.type.*;
import mondrian.spi.UserDefinedFunction;
import org.apache.log4j.Logger;

public class PlusOneUdf implements UserDefinedFunction {
    private static final Logger logger = Logger.getLogger(PlusOneUdf.class);

    public PlusOneUdf() {
    }

    public String getName() {
        return "PlusOne";
    }

    public String getDescription() {
        return "Returns its argument plus or minus one";
    }

    public Syntax getSyntax() {
        return Syntax.Function;
    }

    public Type getReturnType(Type[] parameterTypes) {
        return new NumericType();
    }

    public Type[] getParameterTypes() {
        return new Type[] {new NumericType()};
    }

    public Object execute(Evaluator evaluator, UserDefinedFunction.Argument[] arguments) {
        final Object argValue = arguments[0].evaluateScalar(evaluator);

        logger.info("Cube name: " + evaluator.getCube().getName());
        for (Member m : evaluator.getMembers())
            logger.info("\tMember: " + m.getName());
        for (Dimension d : evaluator.getCube().getDimensions()) 
            logger.info("\tDimension: " + d.getName());

        if (argValue instanceof Number) {
            return new Double(((Number) argValue).doubleValue() + 1);
        } else {
            // Argument might be a RuntimeException indicating that
            // the cache does not yet have the required cell value. The
            // function will be called again when the cache is loaded.
            return null;
        }
    }

    public String[] getReservedWords() {
        return null;
    }
}
