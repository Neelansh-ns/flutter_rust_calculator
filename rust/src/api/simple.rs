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
pub fn calculate_expression(expression: String) -> Result<String, EvalError<f64>> {
    let mut c = Computer::<f64>::default();

    let result: Result<f64, rsc::EvalError<f64>> = c.eval(&expression);
    match result {
        Ok(result) => Ok(result.to_string()),
        Err(error) => Err(error),
    }
}