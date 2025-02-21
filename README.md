[![DOI](https://zenodo.org/badge/894243495.svg)](https://doi.org/10.5281/zenodo.14861520)

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/DaveEdge1/qpt_mixsiar/HEAD?url=rstudio)

![example workflow](https://github.com/kurtlindberg/qpt_mixsiar/actions/workflows/main.yml/badge.svg)

# qpt_mixsiar

Scripts for plant wax mixing model (MixSIAR) experiments and results processing for Lake QPT, Baffin Island, Nunavut, Canada (Lindberg et al., in prep).

**Manuscript title**: Bayesian modeling plant wax sources to an Eastern Canadian Arctic lake sediment record reveals stable plant wax vegetation sources following postglacial shrub colonization

**Authors**: Kurt R. Lindberg, Elizabeth K. Thomas, Martha K. Raynolds, Helga Bultmann

## Study site: Lake Qaupat (QPT)

Lake Qaupat (QPT) is located in southern Baffin Island near the city of Iqaluit and Frobisher Bay (63.68&deg;N, 68.20&deg;W). The modern catchment vegetation is predominantly shrubs on land, including *Betula nana* and *Salix arctica*, and submerged aquatic mosses within the lake, such as *Calliergon richardsonii* (Hollister et al., 2022).

Sedimentary ancient DNA (*seda*DNA) evidence revealed that *Betula* sp. first colonized the catchment at 6.1 ka (Crump et al., 2019), following local Laurentide Ice Sheet deglaciation around ~9-8 ka (Miller, 1980). However, *seda*DNA can only be interpreted on a presence/absence basis, leaving questions about how the overall catchment vegetation community and biomass may have changed following *Betula* sp. colonization.

To address these questions, we use the Bayesian mixing model framework, MixSIAR (Stock et al., 2018), to quantitatively estimate the sources of plant waxes post-*Betula* sp. colonization to represent changes in vegetation/biomass. 

**[INSERT FIGURE HERE]**

## Data: Plant wax *n*-alkanoic acids

We use plant wax *n*-alkanoic acid carbon chain-length distributions and $`\delta`$<sup>13</sup>C as tracers to model the contributions of different endmember priors. $`\delta`$<sup>13</sup>C values are used as the primary tracers and are weighted by the concentration of each carbon chain-length (Upadhayay et al., 2018).


## MixSIAR Workflow

1. **Generate model input files**
   
- **Mix**: Mixture files are the $`\delta`$<sup>13</sup>C values of specified *n*-alkanoic acid carbon chain-lengths in Lake QPT sediments. Downcore sediment measurements (Age $\geq$ -39 cal yr BP) are from this study, while other samples are from Hollister et al. (2022). These files are currently not produced by qpt_mixsiar_makeinputs.ipynb.
  
- **Source**: Means and standard deviations of user-defined vegetation endmembers in qpt_mixsiar_makeinputs.ipynb. Endmember statistics are created from individual samples in "qpt_plantwax_source.xlsx".
   - Note (02/11/2025): Published Lake QPT plant wax endmember data (Hollister et al., 2022; DOI: https://doi.org/10.1029/2022JG006903) currently available. Eastern Canadian Arctic plant wax data not yet published as part of Lindberg et al. (in prep): *Ecological and environmental controls on plant wax production and stable isotope fractionation in modern terrestrial Arctic vegetation*
   - Lake QPT plant wax endmember data from Hollister et al. (2022) is publically available on figshare: https://figshare.com/s/96c3bd6c11bae87c1e28?file=34381742

- **Discr**: Discrimination factors that account for potential alteration/fractionation between the endmember and mixture. These factors are not well-defined in sedimentary mixing studies (Menges et al., 2020), so the Python input script sets them all to "0".

2. **Run model experiments**

- MixSIAR experiements are run using qpt_mixsiar.R (Jupyter Notebook version in progress). The script is set to output two files upon model completion:
  
   1. **output_summary**: Lists model-calculated proportional (out of 1) contributions for each endmember as a mean, standard deviation, and percentile values.
  
   2. **diagnostics**: Determines if the model run reached sufficient convergence as dictated by the Gelman and Geweke diagnostic criteria described in each file.
   
3. Generate plots from output summaries (In progress)

## References

Crump, S. E., Miller, G. H., Power, M., Sepúlveda, J., Dildar, N., Coghlan, M., & Bunce, M. (2019). Arctic shrub colonization lagged peak postglacial warmth: Molecular evidence in lake sediment from Arctic Canada. Global Change Biology, 25(12), 4244-4256.

Hollister, K. V., Thomas, E. K., Raynolds, M. K., Bültmann, H., Raberg, J. H., Miller, G. H., & Sepúlveda, J. (2022). Aquatic and terrestrial plant contributions to sedimentary plant waxes in a modern Arctic lake setting. Journal of Geophysical Research: Biogeosciences, 127(8), e2022JG006903.

Lindberg, K.R., Thomas, E.K., Raynolds, M.K., Bultmann, H. 2024 (talk). Evaluating plant waxes as tracer for reconstructing mid-late Holocene vegetation change in a sourthern Baffin Island lake catchment. The 52nd International Arctic Workshop, Amherst, MA, Mar. 13-16.

Menges, J., Hovius, N., Andermann, C., Lupker, M., Haghipour, N., Märki, L., & Sachse, D. (2020). Variations in organic carbon sourcing along a trans-Himalayan river determined by a Bayesian mixing approach. Geochimica et Cosmochimica Acta, 286, 159-176.

Miller, G. H. (1980). Late foxe glaciation of southern Baffin Island, NWT, Canada. Geological Society of America Bulletin, 91(7), 399-405.

Stock, Brian C., Andrew L. Jackson, Eric J. Ward, Andrew C. Parnell, Donald L. Phillips, and Brice X. Semmens. "Analyzing mixing systems using a new generation of Bayesian tracer mixing models." PeerJ 6 (2018): e5096.

Upadhayay, H. R., Bodé, S., Griepentrog, M., Bajracharya, R. M., Blake, W., Cornelis, W., & Boeckx, P. (2018). Isotope mixing models require individual isotopic tracer content for correct quantification of sediment source contributions. Hydrological Processes, 32(7), 981-989.


