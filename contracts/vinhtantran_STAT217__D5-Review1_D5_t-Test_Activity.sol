\setSolnMargins{21.75pt}
\noindent\begin{eqequestions}
\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.1}{\makebox[0pt][r]{\textbf{1.\ }}}\eqterminex
Yes, the mean snow depth for forested location appears smaller than the mean snow depth of unforested locations based on the beanplots and the sample means.
\ReturnTo{page.2}{\mbox{}}\endeqEXt\par{{}}

$H_0: \mu_{unf} = \mu_{for}$ where $\mu_{unf}$ is the true mean snow depth of unforested locations in the West Fork Basin and $\mu_{for}$ is the true mean snow depth of forested locations in the West Fork Basin.
\ReturnTo{page.2}{\mbox{}}\endeqEXt\par{{}}

There is no association between forest cover and snow depth in the West Fork Basin.
\ReturnTo{page.2}{\mbox{}}\endeqEXt\par{{}}

$y_{ij} = \mu + \varepsilon_{ij}$ where $\varepsilon_{ij} \sim{} N(0,\sigma^2)$ is the random error and $\mu$ is the true mean snow depth of any location in the West Fork Basin.
\ReturnTo{page.2}{\mbox{}}\endeqEXt\par{{}}

$H_A: \mu_{unf} \neq \mu_{for}$ where $\mu_{unf}$ is the true mean snow depth of unforested locations in the West Fork Basin and $\mu_{for}$ is the true mean snow depth of forested locations in the West Fork Basin.
\ReturnTo{page.2}{\mbox{}}\endeqEXt\par{{}}

There is an association between forest cover and snow depth in the West Fork Basin.
\ReturnTo{page.2}{\mbox{}}\endeqEXt\par{{}}

$y_{ij} = \mu_j + \varepsilon_{ij}$ where $\varepsilon_{ij} \sim{} N(0,\sigma^2)$ is the random error and $\mu_j$ is the true mean snow depth for locations in the West Fork Basin that are forested ($j=1$) or locations that are unforested ($j=2$)
\ReturnTo{page.2}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.7}{\makebox[0pt][r]{\textbf{7.\ }}}\eqterminex
$t = 3.71$, it is a t-statistic
\ReturnTo{page.3}{\mbox{}}\endeqEXt\par{{}}

Unforested - Forested
\ReturnTo{page.3}{\mbox{}}\endeqEXt\par{{}}

Under the null hypothesis, the t-statistic follows a t-distribution with 1015 degrees of freedom. What this means is that if there were no association between forest cover and snow depth then a sample of size 1017 would yield a t-statistic value with probabilities determined by the t-distribution with 1015 degrees of freedom.
\ReturnTo{page.4}{\mbox{}}\endeqEXt\par{{}}

p-value=0.0002: This means that there approximately is a 0.02\% chance of observing a difference in mean snow depth as or more extreme then the difference oberved in the West Fork Basin, if there truly is no association between forest cover and snow depth.
\ReturnTo{page.4}{\mbox{}}\endeqEXt\par{{}}

0 or none
\ReturnTo{page.5}{\mbox{}}\endeqEXt\par{{}}

The output says the p-value is 0, but we know that there exists at least one permutation with a t-statistic as or more extreme than our observed one (that is the one observed). Therefore the p-value $<0.001$.
\ReturnTo{page.5}{\mbox{}}\endeqEXt\par{{}}

The spreads and shapes are very similar. The p-value obtained should be roughly equal between the two methods.
\ReturnTo{page.5}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.10}{\makebox[0pt][r]{\textbf{10.\ }}}\eqterminex
At the 5\% significance level, we reject the null hypothesis.
\ReturnTo{page.5}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.11}{\makebox[0pt][r]{\textbf{11.\ }}}\eqterminex
There is very strong evidence to support the claim that there is an association between forest cover and snow depth in the West Fork Basin. As the forest cover (forested or not) was not randomly assigned to locations we cannot infer a causal relationship between forest cover and snow depth. As the locations were randomly sampled from the areas in the West Fork Basin, we can infer this association holds for all areas in the West Fork Basin.
\ReturnTo{page.5}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.12}{\makebox[0pt][r]{\textbf{12.\ }}}\eqterminex
$\bar{x}_{unf} - \bar{for}_0 = -146.69$ mm
\ReturnTo{page.6}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.13}{\makebox[0pt][r]{\textbf{13.\ }}}\eqterminex
The parametrically obtained CI: (69.11, 224.27) \bf Note: \it The order of subtraction from \tt t.test() \it was unforested - forested, the \tt diffmean() \it function does the subtraction differently.
\ReturnTo{page.6}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.14}{\makebox[0pt][r]{\textbf{14.\ }}}\eqterminex
The nonparametrically obtained CI: (-228.38, -71.39) mm
\ReturnTo{page.6}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.15}{\makebox[0pt][r]{\textbf{15.\ }}}\eqterminex
We are 95\% confident that the true mean snow depth of forested locations in the West Fork Basin is between 228.38 mm and 71.39 mm less than the true mean snow depth of unforested locations in the West Fork Basin.
\ReturnTo{page.6}{\mbox{}}\endeqEXt\par{{}}

\eqEXt{}{}\solnItemMngt\exerSolnHeader{}{ex.16}{\makebox[0pt][r]{\textbf{16.\ }}}\eqterminex
Yes. We found that our confidence interval for the difference in true means did not contain 0, meaning value of 0 (the null hypothesized value) is not a plausible value the difference in true mean snow depths. If it is not a plausible value, then we should reject the null hypothesis, which is what we did in (9b).
\ReturnTo{page.6}{\mbox{}}\endeqEXt\par{{}}

\end{eqequestions}

\btwnExamSkip

