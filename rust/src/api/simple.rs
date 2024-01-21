extern crate rsc;
use rsc::{computer::Computer, EvalError};

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn calculate_expression(expression: String) -> Result<String, String> {
    let mut c = Computer::<f64>::default();

    let result: Result<f64, rsc::EvalError<f64>> = c.eval(&expression);
    match result {
        Ok(result) => Ok(result.to_string()),
        Err(error) => Err(error_to_string(error)),
    }
}

fn error_to_string(value: EvalError<f64>) -> String {
    match value {
        EvalError::ComputeError(compute_err) => format!("ComputeError: {:?}", compute_err),
        EvalError::ParserError(parser_err) => format!("ParserError: {:?}", parser_err),
        EvalError::LexerError(lexer_err) => format!("LexerError: {:?}", lexer_err),
    }
}