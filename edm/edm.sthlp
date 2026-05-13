{smcl}
{cmd:help edm}{right: ({browse "https://doi.org/10.1177/1536867X211000030":SJ21-1: st0635})}
{hline}

{marker title}{...}
{title:Title}

{p2colset 5 12 14 2}{...}
{p2col:{cmd:edm} {hline 2}}Empirical dynamic modeling and convergent cross-mapping{p_end}


{title:Syntax}

{p 4 4 2}
The {cmd:edm} package implements a series of tools that can be used for
empirical dynamic modeling in Stata.  The command has two main subcommands,
{opt explore} and {opt xmap}, and two utility subcommands.

{p 4 4 2}
The {cmd:explore} subcommand follows the syntax below and supports either one
or two variables for exploration using simplex projection or S-mapping.

{p 8 12 2}
{cmd:edm} {cmd:explore} {it:varlist} [{it:if}]
[{cmd:,} 
{opt e(numlist)}
{opt tau(integer)}
{opt theta(numlist)}
{opt k(integer)}
{opt alg:orithm(string)}
{opt rep:licate(integer)}
{opt dot(integer)}
{opt tp(integer)}
{opt seed(integer)}
{opt p:redict(varname)}
{opt cop:redict(varname)}
{opt copredictvar(varlist)}
{opt cross:fold(integer)}
{opt ci(integer)}
{opt extra:embed(varlist)}
{opt allowmiss:ing}
{opt missing:distance(real)}
{opt dt}
{opt dtw:eight(real)}
{opt dts:ave(varname)}
{opt det:ails}
{opt full}
{opt force} 
{opt reportrawe}]

{p 4 4 2}
The {cmd:xmap} subcommand performs convergent cross-mapping (CCM).  {cmd:xmap}
follows the syntax below and requires two variables in {it:varlist}.  Though
most options are shared with the {cmd:explore} subcommand, some differences
exist given the different purpose of the analysis.

{p 8 12 2}
{cmd:edm} {cmd:xmap} {it:varlist} [{it:if}]
[{cmd:,} 
{opt e(integer)}
{opt tau(integer)}
{opt theta(real)}
{opt l:ibrary(numlist)}
{opt k(integer)}
{opt alg:orithm(string)}
{opt rep:licate(integer)}
{opt dot(integer)}
{opt tp(integer)}
{opt di:rection(string)}
{opt seed(integer)}
{opt p:redict(varname)}
{opt cop:redict(varname)}
{opt copredictvar(varlist)}
{opt ci(integer)}
{opt extra:embed(varlist)}
{opt allowmiss:ing}
{opt missing:distance(real)}
{opt dt}
{opt dtw:eight(real)}
{opt dts:ave(varname)}
{opt oneway}
{opt det:ails}
{opt force}
{opt save:smap(string)}]

{p 4 4 2}
The syntax for each utility subcommand is as follows:

{p 8 12 2}
{cmd:edm update} [{cmd:, develop replace}]

{p 8 12 2}
{cmd:edm version}


{title:Description}

{p 4 4 2}
The {cmd:edm} package implements a series of tools that can be used for
empirical dynamic modeling in Stata.  The core algorithm is written in Mata to
achieve reasonable execution speed.  A dataset must be declared as time-series
or panel data by the {cmd:tsset} or {cmd:xtset} command prior to using the
{cmd:edm} command, and time-series operators including {cmd:l.}, {cmd:f.},
{cmd:d.}, and {cmd:s.} can be used (the last for seasonal-differencing).


{marker options}{...}
{title:Options}

    {title:Options for the explore and xmap subcommands}

{phang}
{opt e(numlist)} specifies in ascending order the number of dimensions E used
for the main variable in the manifold reconstruction.  If a list of numbers is
provided, the command will compute results for all numbers specified.  The
{cmd:xmap} subcommand only supports a single integer as the option, whereas
the {cmd:explore} subcommand supports a {it:numlist}.  The default is
{cmd:e(2)}, but in theory E can range from 2 to almost half of the total
sample size.  The actual E used in the estimation may be different if
additional variables are incorporated.  An error message occurs if the
specified value is out of range.  Missing data will limit the maximum E under
the default deletion method.

{phang}
{opt tau(integer)} allows researchers to specify the time delay, which
essentially sorts the data by the multiple tau.  This is done by specifying
lagged embeddings that take the form: t, t-tau, ..., t-(E-1)tau, where the
default is {cmd:tau(1)} (that is, typical lags).  However, if {cmd:tau(2)} is
set, then every other t is used to reconstruct the attractor and make
predictions -- this does not halve the observed sample size because both odd
and even t would be used to construct the set of embedding vectors for
analysis.  This option is helpful when data are oversampled (that is, spaced
too closely in time) and therefore very little new information about a dynamic
system is added at each occasion.  The {cmd:tau()} setting is also useful if
different dynamics occur at different times scales and can be chosen to
reflect a researcher's theory-driven interest in a specific time scale (for
example, daily instead of hourly).  Researchers can evaluate whether tau > 1
is required by checking for large autocorrelations in the observed data (for
example, using Stata's {cmd:corrgram} command).  Of course, such a linear
measure of association may not work well in nonlinear systems, and thus
researchers can also check performance by examining rho and mean absolute
error (MAE) at different values of tau.

{phang}
{opt theta(numlist)} specifies in ascending order the distance weighting
parameter for the local neighbors in the manifold.  It is used to detect the
nonlinearity of the system in the {cmd:explore} subcommand for S-mapping.  For
simplex projection and CCM, a weight of {cmd:theta(1)} is applied to neighbors
based on their distance, which is reflected in the default of {cmd:theta(1)}.
However, this can be altered even for simplex projection or CCM (two cases
that we do not cover here).  Particularly, values for S-mapping to test for
improved predictions as they become more local may include the following
option:
{cmd:theta(0 .00001 .0001 .001 .005 .01 .05 .1 .5 1 1.5 2 3 4 6 8 10)}.

{phang}
{opt library(numlist)} is only available with the {cmd:xmap} subcommand.
{cmd:library()} specifies in ascending order the total library size L used for
the manifold reconstruction.  Varying the library size is used to estimate the
convergence property of the cross-mapping, with a minimum value Lmin = E + 2
and the maximum equal to the total number of observations minus sufficient
lags (for example, in the time-series case without missing data, this is Lmax
= T + 1 - E).  An error message is given if the L value is beyond the allowed
range.  To assess the rate of convergence (that is, the rate at which rho
increases as L grows), the full range of library sizes at small values of L
can be used, such as if E = 2 and T = 100, with the setting then perhaps being
{cmd:library(4(1)25 30(5)50 54(15)99)}.

{phang}
{opt k(integer)} specifies the number of neighbors used for prediction.  When
set to {cmd:k(1)}, only the nearest neighbor is used.  As k increases, the
next-closest nearest neighbors are included for making predictions.  In the
case of {cmd:k(0)}, the default value, the number of neighbors used is
calculated automatically (typically as k = E + 1 to form a simplex around a
target).  When k < 0 (for example, {cmd:k(-1)}), all possible points in the
prediction set are used (that is, all points in the library are used to
reconstruct the manifold and predict target vectors).  This latter setting is
useful and typically recommended for S-mapping because it allows all points in
the library to be used for predictions with the weightings in {cmd:theta()}.
However, with large datasets this may be computationally burdensome, and
therefore {cmd:k(100)} or perhaps {cmd:k(500)} may be preferred if T or NT is
large.

{phang}
{opt algorithm(string)} specifies the algorithm used for prediction.  By
default, simplex projection (a locally weighted average) is used.  Valid
options include {cmd:simplex} and {cmd:smap}, the latter of which is a
sequential locally weighted global linear mapping (S-map).  With the
{cmd:xmap} subcommand, where two variables predict each other,
{cmd:algorithm(smap)} invokes something analogous to a distributed lag model
with E + 1 predictors (including a constant term c) and, thus, E + 1 locally
weighted coefficients for each predicted observation/target vector -- because
each predicted observation has its own type of regression done with k
neighbors as rows and E + 1 coefficients as columns.  As noted below, special
options are available to save these coefficients for postprocessing, but it is
not actually a regression model and instead should be seen as a manifold.

{phang}
{opt replicate(integer)} specifies the number of repeats for estimation.  The
{cmd:explore} subcommand uses a random 50/50 split for simplex projection and
S-maps, whereas the {cmd:xmap} subcommand selects the observations randomly
for library construction if the size of the library L is smaller than the size
of all available observations.  In these cases, results may be different in
each run because the embedding vectors (that is, the E-dimensional points)
used to reconstruct a manifold are chosen at random.  The {cmd:replicate()}
option takes advantage of this to allow repeating the randomization process
and calculating results each time.  This is akin to a nonparametric bootstrap
without replacement and is commonly used for inference using confidence
intervals (CIs) in empirical dynamic modeling (Tsonis et al. 2015; van Nes et
al. 2015; Ye et al. 2015).  When, for example, {cmd:replicate(50)} is
specified, mean values and the standard deviations of the results are reported
across the 50 runs by default.  As we note below, it is possible to save all
estimates for postprocessing using typical Stata commands, such as allowing
the graphing of results with the {cmd:svmat} command or finding
percentile-based measures with the {cmd:pctile} command.

{phang}
{opt dot(integer)} controls the appearance of the progress bar when the
{cmd:replicate()} or {cmd:crossfold()} option is specified.  The default is
{cmd:dot(1)} or one dot for each completed cross-mapping estimation.
{cmd:dot(0)} removes the progress bar.

{phang}
{opt tp(integer)} adjusts the default forward-prediction period.  By default,
the {cmd:explore} mode uses {cmd:tp(1)} and the {cmd:xmap} mode uses
{cmd:tp(0)}.  To show results for predictions made two periods into the
future, for example, use {cmd:tp(2)}.

{phang}
{opt direction(string)} is only available with the {cmd:xmap} subcommand.
{cmd:direction()} allows users to control whether the cross-mapping is
calculated bidirectionally or unidirectionally (which reduces computation
times if bidirectional mappings are not required).  Valid options include
{cmd:oneway} and {cmd:both}, the latter of which is the default and computes
both possible cross-mappings.  When {cmd:oneway} is chosen, the first variable
listed after the {cmd:xmap} subcommand is treated as the potential dependent
variable, so {cmd:edm xmap x y, direction(oneway)} produces the cross-mapping
Y|M_X, which pertains to a Y -> X effect.  This is consistent with the
{cmd:beta1_} coefficients from the {cmd:savesmap(beta)} option.  On this
point, the {cmd:direction(oneway)} option may be especially useful when an
initial {cmd:edm xmap x y} procedure shows convergence only for a
cross-mapping Y|M_X, which pertains to a Y -> X effect.  To save time with
large datasets, any follow-up analyses with the {cmd:algorithm(smap)} option
can then be conducted with
{cmd:edm xmap x y, algorithm(smap) savesmap(beta) direction(oneway)}.  To make
this easier, there is also a simplified {cmd:oneway} option that implies
{cmd:direction(oneway)}.

{phang}
{opt seed(integer)} specifies the random-number seed for reproducibility.

{phang}
{opt predict(varname)} allows saving the internal predicted values as a
variable, which could be useful for plotting and diagnostics as well as
forecasting.

{phang}
{opt copredict(varname)} allows you to save the coprediction result as a
variable.  You must specify the {opt copredictvar(varlist)} option for this to
work.

{phang}
{opt copredictvar(varlist)} is used together with the {cmd:copredict()} option
and specifies the variables used for coprediction.  The number of variables
must match the main variables specified.

{phang}
{opt crossfold(integer)} is only available with the {cmd:explore} subcommand.
{cmd:crossfold()} asks the program to run a cross-fold validation of the
predicted variables.  {cmd:crossfold(5)} indicates a 5-fold cross validation.
Note that this cannot be used together with {cmd:replicate()}.

{phang}
{opt ci(integer)} reports the CI for the mean of the estimates (MAE and rho),
as well as the percentiles of their distribution when used with
{cmd:replicate()} or {cmd:crossfold()}.  The first row of output labeled
{cmd:Est. mean CI} reports the estimated CI of the mean rho, assuming that rho
has a normal distribution -- estimated as the corrected sample standard
deviation (with N-1 in the denominator) divided by the square root of the
number of replications.  The reported range can be used to compare mean rho
across different (hyper) parameter values (for example, different E, theta, or
L) using the same datasets as if the sample were the entire population (such
that uncertainty is reduced to 0 when the number of replications -> infinity).
These intervals can be used to test which (hyper) parameter values best
describe a sample, as might be typical when using cross-fold validation
methods.  The row labeled with {cmd:Pc (Est.)} follows the same normality
assumption and reports the estimated percentile values based on the corrected
sample standard deviation of the replicated estimates.  The row labeled
{cmd:Pc (Obs.)} reports the actual observed percentile values from the
replicated estimates.  In both {cmd:Pc (Est.)} and {cmd:Pc (Obs.)}, the
percentile values offer alternative metrics for comparisons across
distributions, which would be more useful for testing typical hypotheses about
population differences in estimates across different (hyper) parameter values
(for example, different E, theta, or L), such as testing whether a dynamic
system appears to be nonlinear in a population (that is, testing whether rho
is maximized when theta > 0).

{pmore}
The number specified within the {cmd:ci()} bracket determines the confidence
level and the locations of the percentile cutoffs.  For example, {cmd:ci(90)}
instructs {cmd:edm} to return 90% CIs as well as the cutoff values for the 5th
and 95th percentile values (because rho and MAE values cannot or are not
expected to take on negative values, we typically prefer one-tailed hypothesis
tests and therefore would use {cmd:ci(90)} to get a one-tailed 95% interval).
These estimated ranges are also included in the {cmd:e()} return list as a
series of scalars with names starting with {cmd:ub} for upper bound and
{cmd:lb} for lower bound values of the CIs.  These return values can be used
for further postprocessing.

{phang}
{opt extraembed(varlist)} allows incorporating additional variables in the
embedding (that is, a multivariate embedding), for example,
{cmd:extraembed(z l.z)} for the variable {cmd:z} and its first lag {cmd:l.z}.
The special prefix for standardization, {cmd:z.}, also works here.

{phang}
{cmd:allowmissing} allows observations with missing values to be used in the
manifold.  Vectors with at least one nonmissing value will be used in the
manifold construction.  When {cmd:allowmissing} is specified, distance
computations are adapted to allow missing values.

{phang}
{opt missingdistance(real)} allows users to specify the assumed distance
between missing values and any values (including missing) when estimating the
Euclidean distance of the vector.  This enables computations with missing
values.  {cmd:missingdistance()} implies {cmd:allowmissing}.  By default, the
distance is set to the expected distance of two random draws in a normal
distribution, which equals 2/sqrt(pi) * standard deviation of the mapping
variable.

{phang}
{cmd:dt} allows automatic inclusion of timestamp-differencing in the
embedding.  Generally, there will be E-1 {cmd:dt} variables included for an
embedding with E dimensions.  By default, the weights used for these
additional variables equal the standard deviation of the main mapping variable
divided by the standard deviation of the time difference.  This can be
overridden by the {cmd:dtweight()} option.  The {cmd:dt} option will be
ignored when running with data with no sampling variation in the time lags.

{phang}
{opt dtweight(real)} specifies the weight used for the timestamp-differencing
variable.

{phang}
{opt dtsave(varname)} allows users to save the internally generated
timestamp-differencing variable.

{phang}
{cmd:oneway} is equivalent to the {cmd:direction(oneway)} option and is also
only available with the {cmd:xmap} subcommand.

{phang}
{cmd:details} asks the program to report the results for all replications
instead of a summary table with mean values and standard deviations when the
{cmd:replicate()} or {cmd:crossfold()} option is specified.  Irrespective of
using this option, all results can be saved for postprocessing.

{phang}
{cmd:full} is available only with the {cmd:explore} subcommand.  {cmd:full}
asks the program to use all possible observations in the manifold construction
instead of the default 50/50 split.  This is effectively the same as
leave-one-out cross-validation because the observation itself is not used for
the prediction.  This may be useful with small samples (for example, T < 50),
where a random split would result in a manifold with an insufficient number of
data points (neighbors) used for calculations when conducting a search for
optimal up to roughly 20.  Sample-size considerations, however, extend beyond
this and include whether data contain runs of repeated values that offer no
unique information for prediction.  Furthermore, one assumption for empirical
dynamic modeling is that a system has been observed across a relevant range of
locations in its state space over time (and preferably, the system will have
evolved through these locations more than once).  When in doubt, use the
{cmd:full} option to take advantage of all information available in a dataset
for manifold reconstruction and prediction.

{phang}
{cmd:force} asks the program to try to continue even if the required number of
unique neighboring observations is not sufficient given the default or
user-specified {cmd:k()}, such as when there are many repeated values that
must be excluded.  This is a common case in past research, where E-length runs
of zeros have been excluded by default because they add no unique information;
see Deyle et al. (2016).

{phang}
{cmd:reportrawe} is available only with the {cmd:explore} subcommand.
{cmd:reportrawe} asks the program to report the number of dimensions
constructed from the main variable that is associated with the requested
{cmd:e()}.  By default, the program reports the actual E used to reconstruct
the manifold, which will include any variables used with the
{cmd:extraembed()} option.

{phang}
{opt savesmap(string)} is available only with the {cmd:xmap} subcommand.
{cmd:savesmap()} allows S-map coefficients to be stored in variables with a
specified prefix.  For example, specifying {cmd:savesmap(beta)} will create a
set of new variables with the prefix {cmd:beta}, such as {cmd:beta1_b0_rep1}.
The specified prefix must not be shared with any variables in the dataset, and
the option is valid only if the {cmd:algorithm(smap)} option is also
specified.

{pmore}
In the newly created variables, the first number immediately after the prefix
is {cmd:1} or {cmd:2} and indicates which of the two listed variables is
treated as the dependent variable in the cross-mapping (that is, it indicates
the direction of the mapping).  If the command is, for example,
{cmd:edm xmap x y, algorithm(smap) savesmap(beta) k(-1)}, then variables
starting with {cmd:beta1_} contain coefficients derived from the manifold M_X
created using the lags of the first variable {cmd:x} to predict Y, or Y|M_X.
This set of variables, therefore, store the coefficients related to {cmd:x} as
an outcome rather than a predictor in CCM.  Any Y -> X effect associated with
the {cmd:beta1_} prefix is shown as Y|M_X, because the outcome is used to
cross-map the predictor, and thus the reported coefficients will be scaled in
the opposite direction of a typical regression (because in CCM, the outcome
variable predicts the cause).

{pmore}
Variables starting with {cmd:beta2_} in the above example store the
coefficients (which will be locally weighted) estimated in the other
direction, where the second listed variable {cmd:y} is used for the manifold
reconstruction M_Y for the mapping X|M_Y, testing the opposite X -> Y effect
in CCM but with reported S-map coefficients that map to a Y -> X regression.
This may be unintuitive, but because CCM causation is tested by predicting the
causal variable with the outcome, to get more familiar regression coefficients
requires reversing CCM's causal direction to a more typical predictor outcome
regression logic.  This can be clarified by reverting to the conditional
notation, such as X|M_Y, which in CCM implies a left to right X -> Y effect,
but for the S-map coefficients will be scaled as a locally weighted regression
in the opposite direction, Y -> X.

{pmore}
Following the {cmd:beta1_} or {cmd:beta2_} is the letter {cmd:b} and a number.
The numerical labeling scheme generally follows the order of the lag for the
main variable and then the order of the extra variables introduced in the case
of multivariate embedding.  {cmd:b0} is a special case that records the
coefficient of the constant term in the regression.

{pmore}
The final term, {cmd:rep1}, indicates that the coefficients are from the first
round of replication (if the {cmd:replicate()} option is not used, then there
is only one).  Finally, the coefficients are saved to match the observation t
in the dataset that is being predicted, which allows plotting each of the E
estimated coefficients against time and the values of the variable being
predicted.  The variables are also automatically labeled for clarity.


    {title:Options for the utility subcommands}

{p 4 4 2}
The {cmd:update} utility subcommand allows the user to update the ado-file.
It supports the following options:

{phang}
{cmd:develop} updates the command to its latest development version.  The
development version usually contains more features but may be less tested
compared with the older version distributed on the Statistical Software
Components archive.

{phang}
{cmd:replace} allows the update to override your local ado-files.

{p 4 4 2}
The {cmd:version} utility subcommand reports the currect version number.  It
has no options.


{title:Examples}

{p 4 4 4}
Chicago crime dataset example (included in the auxiliary file) 

{phang2}
{cmd:. use chicago}{p_end}
{phang2}
{cmd:. edm explore temp, e(2/30)}{p_end}
{phang2}
{cmd:. edm xmap temp crime}{p_end}
{phang2}
{cmd:. edm xmap temp crime, algorithm(smap) savesmap(beta) e(6) k(-1)}


{title:Updates}

{phang}
To install the stable version or update directly through Stata:

{phang2}
{cmd:. edm update, replace}

{phang}
To install the development version directly through Stata:

{phang2}
{cmd:. edm update, develop replace}


{title:Suggested citation}

{phang}
Li, J., M. J. Zyphur, G. Sugihara, and P. J. Laub. 2021. Beyond linearity,
stability, and equilibrium: The edm package for empirical dynamic modeling and
convergent cross-mapping in Stata.
{it:Stata Journal} 21: 220-258.
{browse "https://doi.org/10.1177/1536867X211000030"}.


{title:References}

{phang}
Deyle, E. R., M. C. Maher, R. D. Hernandez, S. Basu, and G. Sugihara. 2016.
Global environmental drivers of influenza. 
{it:Proceedings of the National Academy of Sciences} 113: 13081-13086. 
{browse "https://doi.org/10.1073/pnas.1607747113"}.

{phang}
Tsonis, A. A., E. R. Deyle, R. M. May, G. Sugihara, K. Swanson, J. D.
Verbeten, and G. Wang. 2015. Dynamical evidence for causality between galactic
cosmic rays and interannual variation in global temperature.
{it:Proceedings of the National Academy of Sciences} 112: 3253-3256.
{browse "https://doi.org/10.1073/pnas.1420291112"}.

{phang}
van Nes, E. H., M. Scheffer, V. Brovkin, T. M. Lenton, H. Ye, E. Deyle, and G.
Sugihara.  2015. Causal feedbacks in climate change. 
{it:Nature Climate Change} 5: 445-448.
{browse "https://doi.org/10.1038/nclimate2568"}.

{phang}
Ye, H., E. R. Deyle, L. J. Gilarranz, and G. Sugihara. 2015. Distinguishing
time-delayed causal interactions using convergent cross mapping.
{it:Scientific Reports} 5: 14750. 
{browse "https://doi.org/10.1038/srep14750"}.


{title:Authors}

{pstd}
Jinjing Li{break}
NATSEM, University of Canberra{break}
Bruce, Australia{break}
{browse "mailto:jinjing.li@canberra.edu.au":jinjing.li@canberra.edu.au}

{pstd}
Michael J. Zyphur{break}
Business & Economics, University of Melbourne{break}
Melbourne, Australia{break}
mzyphur@unimelb.edu.au

{pstd}
George Sugihara{break}
Scripps Institution of Oceanography, UCSD{break}
La Jolla, CA{break}
gsugihara@ucsd.edu

{pstd}
Patrick J. Laub{break}
Business & Economics, University of Melbourne{break}
Melbourne, Australia{break}
patrick.laub@unimelb.edu.au


{marker alsosee}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 21, number 1: {browse "https://doi.org/10.1177/1536867X211000030":st0635}{p_end}
