use std::{env, error::Error};

fn main() -> Result<(), Box<dyn Error>> {
    let runtime_api: String = env::var("AWS_LAMBDA_RUNTIME_API")?;
    loop {
        // gets the next invocation
        let url = format!("http://{runtime_api}/2018-06-01/runtime/invocation/next");
        let request = ureq::get(&url).call()?;
        let req_id = request
            .header("Lambda-Runtime-Aws-Request-Id")
            .ok_or("ERROR: Bad request")?;

        // reponds to the invocation
        let url = format!("http://{runtime_api}/2018-06-01/runtime/invocation/{req_id}/response");
        ureq::post(&url).send_string("Hello, World!")?;
    }
}
