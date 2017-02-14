class App extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            example: { input: "", history: [], snapshot: [], strong: false },
            loading: false,
        }
        this.handleChange = this.handleChange.bind(this)
        this.handleSubmit = this.handleSubmit.bind(this)
        this.handleClick = this.handleClick.bind(this)
        this.handleCheck = this.handleCheck.bind(this)
    }
    
    componentDidMount() {
        // this.input.focus()
        this.post()
    }

    handleChange(event) {
        const { example } = this.state
        example.input = event.target.value
        this.setState({ example })
    }

    handleSubmit(e) {
        e.preventDefault()
        this.post()
    }

    handleClick(e, i, j) {
        e.preventDefault()
        const { example } = this.state
        example.input = `${String.fromCharCode(96 + j)}${i}`
        this.setState({ example })
        this.post()
    }

    handleCheck(e) {
        const { example } = this.state
        example.strong = e.target.checked
        this.setState({ example })
    }

    post() {
        this.setState({ loading: true })
        const { example } = this.state
        
        const headers = new Headers()
        headers.append('Content-Type', 'application/json')
        fetch('/example', {
              method: 'POST',
              headers: headers,
              body: JSON.stringify(example),
        })
        .then(response => response.json())
        .then(example => {
              example.input = ''
              this.setState({ example, loading: false })
        })
    }

    render() {
        const { example, loading } = this.state
        return (
            <div>
                {/*
                <form className="my-4" onSubmit={ this.handleSubmit }>
                    <div className="form-group">
                        <input type="text" className="form-control form-control-lg" value={ example.input } onChange={ this.handleChange } ref={ input => this.input = input } />
                    </div>
                    <div className="form-group">
                        <input type="submit" className="btn btn-secondary btn-block btn-lg" disabled={loading} />
                    </div>
                </form>
                */}
                { example.output && <div className="my-4">
                    {/* <div className="row">
                        <div className="col-4">
                            <pre>{ example.history }</pre>
                            <hr />
                            <pre>{ example.snapshot }</pre>
                        </div>
                        <div className="col-8">
                            <pre>{ example.output }</pre>
                        </div>
                    </div> */}
                    <p>Black: {example.numBlack}, White: {example.numWhite}</p>
                    <div className="board clearfix">
                        { example.output.split('\n').map((row, i) =>
                            row.split('').map((col, j) =>
                                <div className={ `piece row${i} col${j}` }>
                                    { (col == 'B' || col == 'W') && <span className={ `disk ${col}` } /> }
                                    { (col == '@') &&
                                        <span className="guide" onClick={ (e) => this.handleClick(e, i, j) } /> }
                                    { /[ a-h0-9]/.test(col) && <span className="label">{ col }</span> }
                                </div>
                            )
                        ).reduce((a, b) => a.concat(b)) }
                    </div>
                    <div className="form-check mt-2">
                        <label className="form-check-label">
                            <input className="form-check-input" type="checkbox" checked={ example.strong } onChange={ this.handleCheck } />
                            {' '}Strong Mode
                        </label>
                    </div>
                </div> }
            </div>
        )
    }
}

ReactDOM.render(<App />, document.querySelector('#app'))
