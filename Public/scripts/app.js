class App extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            example: { input: "", color: 1, snapshot: [], strong: false },
            loading: false,
        }
        this.handleClick = this.handleClick.bind(this)
        this.handleCheck = this.handleCheck.bind(this)
    }
    
    componentDidMount() {
        this.post('', 1)
    }

    handleClick(e, i, j) {
        e.preventDefault()
        const input = input
        this.post(`${String.fromCharCode(96 + j)}${i}`, 1).then(() => {
            setTimeout(() => this.post('go', 2), 100)
        })
    }

    handleCheck(e) {
        const { example } = this.state
        example.strong = e.target.checked
        this.setState({ example })
    }

    post(input, color) {
        const { example, loading } = this.state
        if (loading) return
        example.input = input
        example.color = color
        this.setState({ example, loading: true })
        
        const headers = new Headers()
        headers.append('Content-Type', 'application/json')

        return fetch('/example', {
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
                { example.output && <div className="my-4">
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
